# ---------- BUILDER ----------
FROM keycloak/keycloak:26.0.4 AS builder

USER root

# 🔹 Kopiera providers och certifikat
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

# 🔹 Kopiera tema
COPY theme /opt/keycloak/theme

# 🔹 Build med PostgreSQL
RUN /opt/keycloak/bin/kc.sh build --db=postgres

# ---------- RUNTIME ----------
FROM keycloak/keycloak:26.0.4

USER root

# 🔁 Kopiera från builder
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# 🔁 Kopiera theme igen (valfritt men robust)
COPY theme /opt/keycloak/theme

# 🔁 Kopiera realm-filen till rätt import-mapp
COPY minvikt_realm.json /opt/keycloak/data/import/minvikt_realm.json

EXPOSE 8080

# 🔁 Start med import och truststore
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm", "-Djavax.net.ssl.trustStore=/opt/keycloak/truststore/truststore.p12", "-Djavax.net.ssl.trustStorePassword=qwerty123", "-Djavax.net.ssl.trustStoreType=PKCS12", "--log-level=DEBUG", "--verbose"]

