# ---- Build stage ----
FROM quay.io/keycloak/keycloak:26.0.4 AS builder
USER root

# Kopiera providers (BankID + Postgres)
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/

# Kopiera certifikat
COPY cert/bankid-root.pem /opt/keycloak/truststore/bankid-root.pem
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12

# Kopiera eventuellt eget tema
COPY theme /opt/keycloak/theme

# Bygg Keycloak med Postgres-stöd
RUN /opt/keycloak/bin/kc.sh build --db=postgres \
  --health-enabled=true \
  --metrics-enabled=true \
  --features=token-exchange

# ---- Runtime stage ----
FROM quay.io/keycloak/keycloak:26.0.4
USER root

COPY --from=builder /opt/keycloak/ /opt/keycloak/

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start","--optimized","--truststore-paths=/opt/keycloak/truststore/bankid-root.pem","--log-level=DEBUG", "--verbose"]
