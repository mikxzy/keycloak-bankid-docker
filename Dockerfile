# ---- Build stage ----
# ---- Build stage ----
FROM quay.io/keycloak/keycloak:26.2.5 AS builder
USER root

# BankID IdP-provider (jar) + PKCS12-filer + ev. tema
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
# (Inget behov av att lägga in egen postgresql-*.jar; den finns i imagen)
COPY cert/keystore.p12 /opt/keycloak/keystore/keystore.p12
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY theme /opt/keycloak/themes/

# Bygg med postgres, health och metrics. (token-exchange om du använder det)
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true \
    --metrics-enabled=true \
    --features=token-exchange

# ---- Runtime stage ----
FROM quay.io/keycloak/keycloak:26.2.5
USER root

COPY --from=builder /opt/keycloak/ /opt/keycloak/
EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start","--optimized","--log-level=INFO"]
