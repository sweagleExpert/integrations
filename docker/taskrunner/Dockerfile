FROM openjdk:8-jdk-alpine

# This is optional ENV parameters that you can set to change taskRunner connection settings to SWEAGLE CORE
#ENV SWEAGLE_TOKEN=XXX \
#    SWEAGLE_USER=taskrunner_user \
#    SWEAGLE_PASSWORD=taskrunner_password

RUN addgroup sweagle && \
    adduser -S -G sweagle sweagle && \
		mkdir -p /opt/SWEAGLE

COPY ./package /opt/SWEAGLE/

RUN chmod +x /opt/SWEAGLE/scripts/*.sh && \
    chown -R sweagle:sweagle /opt/SWEAGLE

USER sweagle

CMD [ "/opt/SWEAGLE/scripts/startTaskRunner.sh" ]
EXPOSE 8082
