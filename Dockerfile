# Bygg Keycloak med extra providers
FROM quay.io/keycloak/keycloak:26.0.4 AS builder

USER root

# Kopiera custom providers
COPY providers/*.jar /opt/keycloak/providers/

# Bygg in providers
RUN /opt/keycloak/bin/kc.sh build

# Slutgiltig image
FROM quay.io/keycloak/keycloak:26.0.4

USER root

# Kopiera från builder
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Exponera port (ändra vid behov)
EXPOSE 8080

# Starta Keycloak (production), använd start-dev för enkel testning utan SSL
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev"]


# Notera: ingen admin/env här, det tas via Railway/Render/GCP env settings!
FROM quay.io/keycloak/keycloak:26.0.4
