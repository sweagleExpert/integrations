FROM library/mongo:3.4
#RUN apt-get update && apt-get upgrade -y

ENV MONGO_INITDB_ROOT_USERNAME root
ENV MONGO_INITDB_ROOT_PASSWORD root_password
ENV MONGO_INITDB_DATABASE admin

VOLUME ["/data/db"]
WORKDIR /data

USER mongodb
#CMD ["/usr/bin/mongod","--bind_ip", "0.0.0.0"]
ADD mongo-init.js /docker-entrypoint-initdb.d/
EXPOSE 27017
