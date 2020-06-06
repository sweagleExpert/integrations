FROM openjdk:8-jdk-alpine
RUN apk add --no-cache bash

# This is optional ENV parameters that you can set to change connection settings to VAULT
#ENV VAULT_ROOT_TOKEN=XXX

# VAULT volume is shared between sweagle-core and vault containers to be able to use vault root-token key in sweagle
# Please, note that /vault volume must be created here in order to change owner before sharing
VOLUME /vault

RUN addgroup sweagle && \
    adduser -S -G sweagle sweagle && \
		mkdir -p /opt/SWEAGLE && \
    mkdir -p /vault

COPY ./package /opt/SWEAGLE

RUN chown -R sweagle:sweagle /opt/SWEAGLE && \
    chown -R sweagle:sweagle /vault && \
    chmod +x /opt/SWEAGLE/scripts/*.sh

USER sweagle

CMD ["/opt/SWEAGLE/scripts/wait-for-it.sh","sweagle-mysql:3306","--strict","--timeout=60","--","/opt/SWEAGLE/scripts/start.sh"]

EXPOSE 8081
