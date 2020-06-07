FROM alpine:3.8
RUN /bin/sh -c "apk add --no-cache bash"

ENV VAULT_ADDR=http://0.0.0.0:8200 \
    PATH="/opt/vault:${PATH}"

# This is optional ENV parameters that you can set to change DB settings
#    VAULT_DB="vault" \
#    VAULT_DB_HOST="sweagle-mysql"
#    VAULT_DB_PORT=3306
#    VAULT_DB_USER="vault_user" \
#    VAULT_DB_PASSWORD="vault_password"
# This is optional ENV parameters that you can set to enable DEBUG
#    DEBUG_VAULT="true"

# Create a vault sweagle user and group first so the IDs get set the same way,
# This is sweagle user as volume is shared with SWEAGLE containers.
# Please, note that /vault path must be created here in order to change owner before sharing
RUN addgroup --gid 1000 sweagle && \
    adduser --uid 100 -S -G sweagle sweagle && \
    mkdir -p /opt/vault && \
    mkdir -p /vault

COPY ./package /opt/vault

# Change ownership of files to be able to read or execute them
RUN chown -R sweagle:sweagle /vault && \
    chown -R sweagle:sweagle /opt/vault && \
    chmod +x /opt/vault/*.sh

# VAULT volume is shared between sweagle-core and vault containers to be able to use vault root-token key in sweagle
# Please, note that /vault volume must be created after path has been created and owner has been put to sweagle user
VOLUME /vault

# Run process as non root user for security purpose
USER sweagle

# Default Timeout=15s, give more time for MySQL to start
CMD ["wait-for-it.sh","sweagle-mysql:3306","--strict","--timeout=60","--","startVault.sh","vault.hcl"]
# This is to use only for local test
#CMD ["wait-for-it.sh","1.1.1.1:80","--strict","--timeout=60","--","startVault.sh","vault-local.hcl"]
EXPOSE 8200
