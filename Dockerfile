# ---- Build stage ----
FROM quay.io/keycloak/keycloak:26.2.5 AS builder
USER root

# BankID IdP-provider (jar) + PKCS12-filer + ev. tema
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
# (Inget behov av att lägga in egen postgresql-*.jar; den finns i imagen)
COPY cert/bankid-root.pem /opt/keycloak/truststore/bankid-root.pem/
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12/


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
CMD ["start","--optimized","-Djavax.net.ssl.trustStore=/opt/keycloak/truststore/truststore.p12","-Djavax.net.ssl.trustStorePassword=qwerty123","-Djavax.net.ssl.trustStoreType=PKCS12","--log-level=INFO"]
