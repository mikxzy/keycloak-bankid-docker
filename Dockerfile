FROM quay.io/keycloak/keycloak:26.2.5 AS builder
USER root

RUN mkdir -p /opt/keycloak/keystore /opt/keycloak/truststore /opt/keycloak/providers

COPY providers/sweden-connect-provider*.jar /opt/keycloak/providers/
COPY providers/postgresql-42.5.4.jar /opt/keycloak/providers/
COPY cert/truststore.p12 /opt/keycloak/truststore/truststore.p12
COPY cert/FPTestcert5_20240610.p12 /opt/keycloak/keystore/FPTestcert5_20240610.p12

RUN /opt/keycloak/bin/kc.sh build --db=postgres

# --------------------------------------------------

FROM quay.io/keycloak/keycloak:26.2.5
USER root

COPY --from=builder /opt/keycloak/ /opt/keycloak/

EXPOSE 8080

# Set correct entrypoint and default command
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]

# Drop privileges if supported
USER keycloak
