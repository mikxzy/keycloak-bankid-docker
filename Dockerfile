
FROM quay.io/keycloak/keycloak:25.0.1 AS builder

USER root

COPY providers/bankid4keycloak-*.jar /opt/keycloak/providers/
COPY cert/bankid-root.pem /opt/keycloak/truststore/bankid-root.pem
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12
# Lägg till Postgres JDBC driver
ADD https://jdbc.postgresql.org/download/postgresql-42.7.3.jar /opt/keycloak/providers/

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:25.0.1

USER root

COPY --from=builder /opt/keycloak/ /opt/keycloak/

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized","--truststore-paths=/opt/keycloak/truststore/bankid-root.pem"]

