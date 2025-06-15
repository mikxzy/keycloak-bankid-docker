# Byggsteg: kopiera in extra providers och bygg Keycloak
FROM quay.io/keycloak/keycloak:26.0.4 AS builder

USER root

# Lägg in din provider-JAR här – byt namn om du har en annan
COPY providers/bankid4keycloak-*.jar /opt/keycloak/providers/

# Bygg om Keycloak med providers
RUN /opt/keycloak/bin/kc.sh build

# Slutgiltig image
FROM quay.io/keycloak/keycloak:26.0.4

USER root

# Kopiera inbyggd Keycloak (med providers) från build-steget
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Exponera port (Railway/Render söker denna)
EXPOSE 8080

# Kör Keycloak, använd start-dev för enkel testning
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev"]
