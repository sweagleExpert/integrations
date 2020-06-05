FROM alpine:3.8
RUN apk add --no-cache bash
RUN apk add --no-cache curl

ENV SWEAGLE_TENANT=sweagle
# If env variables below are not provided they will be defaulted in createTenant script
#    SWEAGLE_ADMIN_USER="admin_${SWEAGLE_TENANT}" \
#    SWEAGLE_ADMIN_PASSWORD="password"
#    SWEAGLE_ADMIN_EMAIL="${SWEAGLE_ADMIN_USER}@${SWEAGLE_TENANT}.com" \
#    SWEAGLE_URL="http://sweagle-core:8081"

RUN mkdir -p /opt/sweagle

COPY ./package /opt/sweagle

RUN chmod +x /opt/sweagle/scripts/*.sh

# Default Timeout=15s, give more time for CORE to start
CMD ["/opt/sweagle/scripts/wait-for-it.sh","sweagle-core:8081","--strict","--timeout=120","--","/opt/sweagle/scripts/createTenant.sh"]
