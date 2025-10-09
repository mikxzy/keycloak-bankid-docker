FROM keycloak/keycloak:26.0.4 AS builder

USER root

# Kopiera providers och certifikat
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

# 🔹 Kopiera custom theme till rätt plats
COPY theme /opt/keycloak/theme

# Kontrollera innehåll
RUN ls -lh /opt/keycloak/truststore/

# ⚠️ BUILD MED HEALTH & METRICS AKTIVERAT ⚠️
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true \
    --metrics-enabled=true \
    --features=token-exchange,admin-fine-grained-authz

# Runtime image
FROM keycloak/keycloak:26.0.4

USER root

# 🔁 Kopiera byggd keycloak med theme och providers
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# 🔁 Kopiera themes separat igen för säkerhets skull
COPY theme /opt/keycloak/theme

# ⚠️ SÄTT ENVIRONMENT VARIABLES FÖR RAILWAY ⚠️
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_PROXY=edge

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start","--optimized","-Djavax.net.ssl.trustStore=/opt/keycloak/truststore/truststore.p12","-Djavax.net.ssl.trustStorePassword=qwerty123","-Djavax.net.ssl.trustStoreType=PKCS12","--log-level=DEBUG","--verbose"]