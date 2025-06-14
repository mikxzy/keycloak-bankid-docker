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
COPY bankid4keycloak-*.jar /opt/keycloak/providers

# Exponera port (Render letar efter EXPOSE 8080)
EXPOSE 8080

# Starta Keycloak på 0.0.0.0:8080 med hostname-strict=false (bra för cloud)
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev", "--http-port=8080", "--hostname-strict=false", "--import-realm" ]

