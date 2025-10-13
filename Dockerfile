# ---- Build stage ----
FROM quay.io/keycloak/keycloak:26.0.4 AS builder

USER root

# Kopiera providers och certifikat
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

# 🔹 Kopiera custom theme till rätt plats
COPY themes /opt/keycloak/themes

# Kontrollera innehåll
RUN ls -lh /opt/keycloak/truststore/

# 🔧 Build med PostgreSQL och custom theme
RUN /opt/keycloak/bin/kc.sh build --db=postgres

# Runtime image
FROM quay.io/keycloak/keycloak:26.0.4

USER root

# 🔁 Kopiera byggd keycloak med theme och providers
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# 🔁 Kopiera themes separat igen för säkerhets skull (valfritt men säkert)
COPY themes /opt/keycloak/themes

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized","-Djavax.net.ssl.trustStore=/opt/keycloak/truststore/truststore.p12","-Djavax.net.ssl.trustStorePassword=qwerty123","-Djavax.net.ssl.trustStoreType=PKCS12","--log-level=DEBUG","--verbose"]

