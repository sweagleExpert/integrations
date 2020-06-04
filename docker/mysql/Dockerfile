FROM mysql:5.7
#RUN apt-get update && apt-get upgrade -y

# Put all user/pwd as environment variables to facilitate update without rebuilding image
# It is also compatibles with secrets variables passed as env args
ENV MYSQL_ROOT_PASSWORD=XXXXXX \
    MYSQL_DATABASE=mdm \
    MYSQL_USER=mdm_user \
    MYSQL_PASSWORD=mdm_password \
    VAULT_DB=vault \
    VAULT_DB_USER=vault_user \
    VAULT_DB_PASSWORD=vault_password

USER mysql
COPY ./conf/my.cnf /etc/mysql/my.cnf
COPY init.sh /docker-entrypoint-initdb.d/
VOLUME /var/lib/mysql

# ENTRYPOINT, CMD and EXPOSE Lines below are optional, as present in MySQL official image
# If you put CMD, put also ENTRYPOINT, as required in order to launch init.sh script
#ENTRYPOINT ["docker-entrypoint.sh"]
#CMD [ "mysqld" ]
#EXPOSE 3306
