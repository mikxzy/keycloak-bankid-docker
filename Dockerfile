FROM keycloak/keycloak:25.0.4 AS builder

USER root

COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

# 🔹 Kopiera custom theme till rätt plats
COPY theme /opt/keycloak/theme

# Kontrollera innehåll
RUN ls -lh /opt/keycloak/truststore/

# Build med PostgreSQL och custom theme
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --features=preview \
    --health-enabled=true \
    --metrics-enabled=true

FROM keycloak/keycloak:25.0.4

USER root

# 🔁 Kopiera byggd keycloak med theme och providers
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# 🔁 Kopiera themes separat igen för säkerhets skull (valfritt men säkert)
COPY theme /opt/keycloak/theme

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]
CMD ["-Djavax.net.ssl.trustStore=/opt/keycloak/truststore/truststore.p12","-Djavax.net.ssl.trustStorePassword=qwerty123","-Djavax.net.ssl.trustStoreType=PKCS12","--log-level=INFO","--verbose"]
