Full Dockerfile för Sweden Connect/BankID-plugin
FROM quay.io/keycloak/keycloak:26.2.5 AS builder 

USER root

# Lägg dina providers här (Sweden Connect JAR + Postgres)
COPY providers/sweden-connect-provider*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/

# Cert och nycklar
COPY cert/bankid-root.pem /opt/keycloak/truststore/bankid-root.pem
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

# Bygg Keycloak och aktivera features + DB
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --features=preview \
    --health-enabled=true \
    --metrics-enabled=true

FROM quay.io/keycloak/keycloak:26.2.5

USER root

# Kopiera färdigbyggd keycloak med providers etc.
COPY --from=builder /opt/keycloak/ /opt/keycloak/

EXPOSE 8080

# Starta utan att försöka ändra byggtids-flaggor igen!
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD [
  "start",
  "--optimized",
  "--truststore-paths=/opt/keycloak/truststore/bankid-root.pem",
  "--log-level=DEBUG",
  "--verbose"
]

