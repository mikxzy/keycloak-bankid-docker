FROM quay.io/keycloak/keycloak:26.0.5 AS builder

COPY providers/bankid4keycloak-*.jar /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.0.5
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Lägg till dessa rader
USER keycloak
RUN /opt/keycloak/bin/kc.sh show-config
RUN /opt/keycloak/bin/kc.sh build --db=postgres

EXPOSE 8080
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
