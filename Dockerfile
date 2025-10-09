FROM keycloak/keycloak:26.0.4 AS builder

USER root

# Kopiera providers och certifikat
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

# Kopiera custom theme
COPY theme /opt/keycloak/theme

# Build med giltiga options
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true \
    --metrics-enabled=true

# Runtime image
FROM keycloak/keycloak:26.0.4

USER root

# Kopiera byggd keycloak
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Färre environment variables för start-dev
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin
ENV KC_HOSTNAME_STRICT=false

EXPOSE 8080

# Använd start-dev för enklare debugging
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev", "--verbose"]