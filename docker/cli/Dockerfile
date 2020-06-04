# Test with FROM alpine:3.8 installing nodejs or FROM node:13-alpine failed
FROM node:slim
RUN apt-get update && apt-get install -y curl jq

COPY ./package /usr/bin/
RUN chmod +x /usr/bin/sweagle && \
    chmod +x /usr/bin/scripts/init-cli.sh
RUN mkdir -p /opt/sweagle

# If you prefer not to use /usr/bin
#COPY ./package /opt/sweagle/
#ENV PATH="/opt/sweagle:${PATH}"
#RUN chmod +x /opt/sweagle/sweagle && chmod +x /opt/sweagle/scripts/init-cli.sh
#ENTRYPOINT ["/opt/sweagle/scripts/init-cli.sh"]

WORKDIR /opt/sweagle
ENTRYPOINT ["/usr/bin/scripts/init-cli.sh"]

# This is if you want to directly use CLI commands from the container
#ENTRYPOINT ["sweagle"]
