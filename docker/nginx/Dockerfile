FROM nginx:1.15.12
#RUN apt-get update
#RUN apt-get upgrade -y
RUN rm -f /etc/nginx/nginx.conf
COPY ./ui/dist/ /usr/share/nginx/html/
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/conf.d/* /etc/nginx/conf.d/
COPY ./scripts/docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    ln -s /usr/local/bin/docker-entrypoint.sh /
RUN mkdir -p /usr/share/nginx/html/downloads/cli
COPY ./cli/* /usr/share/nginx/html/downloads/cli/
ENTRYPOINT ["docker-entrypoint.sh"]
