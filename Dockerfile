# Bygg Keycloak med extra providers
FROM quay.io/keycloak/keycloak:25.0.4 AS builder

ARG KC_HEALTH_ENABLED KC_METRICS_ENABLED KC_FEATURES KC_DB KC_HTTP_ENABLED PROXY_ADDRESS_FORWARDING QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY KC_HOSTNAME KC_LOG_LEVEL KC_DB_POOL_MIN_SIZE

# Ladda ner extra externa providers

# Kopiera in egna providers (t ex din bankid4keycloak-*.jar)
COPY providers/*.jar /opt/keycloak/providers/

# Teman om du använder det
COPY /theme/keywind /opt/keycloak/themes/keywind

# Bygg Keycloak
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest

# Om du har någon extra java.config, annars kan du ta bort denna rad
COPY java.config /etc/crypto-policies/back-ends/java.config

COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Exponera porten (valfritt)
EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

# Production: ["start", "--optimized"]
# Dev/test:   ["start-dev"]
CMD ["start", "--optimized", "--import-realm"]
