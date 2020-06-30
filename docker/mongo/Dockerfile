FROM library/mongo:3.4
#RUN apt-get update && apt-get upgrade -y

ENV MONGO_INITDB_ROOT_USERNAME="root" \
    MONGO_INITDB_ROOT_PASSWORD="root_password" \
    MONGO_INITDB_DATABASE="admin"

### OPTIONAL ENV PARAMETERS TO SET SWEAGLE DB
#ENV    MONGO_DB="sweagle" \
#    MONGO_DB_USER="staticTreeUser" \
#    MONGO_DB_PASSWORD="staticTreePassword"

VOLUME ["/data/db"]
WORKDIR /data

USER mongodb
ADD mongo-init.sh /docker-entrypoint-initdb.d/
#CMD ["/usr/bin/mongod","--bind_ip", "0.0.0.0"]
EXPOSE 27017
