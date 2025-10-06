
FROM quay.io/keycloak/keycloak:26.2.5 AS builder

USER root

COPY providers/sweden-connect-provider*.jar /opt/keycloak/providers/

COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

# Build with PostgreSQL support
RUN /opt/keycloak/bin/kc.sh build --db=postgres

FROM quay.io/keycloak/keycloak:26.2.5

USER root


COPY --from=builder /opt/keycloak/ /opt/keycloak/

EXPOSE 8080

CMD ["start", "--optimized"]
ENV JAVA_OPTS="-Djavax.net.ssl.trustStore=/opt/keycloak/truststore/truststore.p12 -Djavax.net.ssl.trustStorePassword=qwerty123 -Djavax.net.ssl.trustStoreType=PKCS12"
