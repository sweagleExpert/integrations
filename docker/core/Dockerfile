FROM openjdk:8-jdk-alpine
RUN apk add --no-cache bash

# This is optional ENV parameters that you can set to change connection settings to VAULT
#ENV VAULT_ROOT_TOKEN=XXX \
#    SWEAGLE_LICENSE=XXX

RUN addgroup --gid 1000 sweagle && \
    adduser --uid 100 -S -G sweagle sweagle && \
		mkdir -p /opt/SWEAGLE && \
    mkdir -p /vault

COPY ./package /opt/SWEAGLE

RUN chown -R sweagle:sweagle /opt/SWEAGLE && \
    chown -R sweagle:sweagle /vault && \
    chmod +x /opt/SWEAGLE/scripts/*.sh

# VAULT volume is shared between sweagle-core and vault containers to be able to use vault root-token key in sweagle
# Please, note that /vault volume must be created after path has been created and owner has been put to sweagle user
VOLUME /vault

USER sweagle

CMD ["/opt/SWEAGLE/scripts/wait-for-it.sh","sweagle-mysql:3306","--strict","--timeout=60","--","/opt/SWEAGLE/scripts/start.sh"]

EXPOSE 8081
