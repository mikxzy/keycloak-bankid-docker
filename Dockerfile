# ---- Build stage ----
FROM quay.io/keycloak/keycloak:25.0.4 AS builder
USER root

# (Valfritt) BankID-IdP-provider JAR
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/

# (Valfritt) Eget tema (OBS! rätt sökväg = themes/)
COPY theme /opt/keycloak/themes/

# Förbered Keycloak med Postgres-stöd + health/metrics
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true \
    --metrics-enabled=true

# ---- Runtime stage ----
FROM quay.io/keycloak/keycloak:25.0.4
USER root

# Ta med det optimerade bygget
COPY --from=builder /opt/keycloak/ /opt/keycloak/

EXPOSE 8080

# Kör bakom proxy; inga --https-* flaggor här
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--log-level=INFO"]
