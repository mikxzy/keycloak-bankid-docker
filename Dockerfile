# ---- Build stage ----
FROM quay.io/keycloak/keycloak:26.0.4 AS builder
USER root

# Lägg in BankID-IdP (sweid4keycloak/bankid4keycloak) och ev. eget tema
# (om du inte har dessa kataloger i repo kan du ta bort COPY-raderna)
COPY providers/bankid4keycloak*.jar /opt/keycloak/providers/
COPY theme /opt/keycloak/themes/

# Förbered Keycloak med Postgres-stöd och nyttiga features
RUN /opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --health-enabled=true \
    --metrics-enabled=true

# ---- Runtime stage ----
FROM quay.io/keycloak/keycloak:26.0.4
USER root

# Ta med den optimerade Keycloak-bygget
COPY --from=builder /opt/keycloak/ /opt/keycloak/

EXPOSE 8080

# Viktigt: kör bakom proxy (Railway/Render). Ingen server-HTTPS här.
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--log-level=INFO"]