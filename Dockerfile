FROM keycloak/keycloak:26.0.4 AS builder

USER root

# Kopiera providers och certifikat
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

# Kopiera custom theme
COPY theme /opt/keycloak/theme

# Build med ALLA nödvändiga konfigurationer
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true \
    --metrics-enabled=true \
    --features=token-exchange,admin-fine-grained-authz \
    --http-enabled=true \
    --hostname-strict=false

# Runtime image
FROM keycloak/keycloak:26.0.4

USER root

# Kopiera byggd keycloak
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Sätt ALLA nödvändiga environment variables
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_PROXY=edge
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Viktigt: Använd KEYCLOAK_ prefix för admin credentials
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin

EXPOSE 8080

# Använd start-dev för development eller felsök först
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev", "--verbose"]