FROM quay.io/keycloak/keycloak:26.0.4 AS builder
COPY providers/*.jar /opt/keycloak/providers/
RUN ls -l /opt/keycloak/providers/

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.0.4
COPY --from=builder /opt/keycloak/ /opt/keycloak/
EXPOSE 8080
CMD ["start"]
