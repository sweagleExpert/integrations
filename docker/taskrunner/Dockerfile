FROM openjdk:8-jdk-alpine

RUN addgroup sweagle && \
    adduser -S -G sweagle sweagle && \
		mkdir -p /opt/SWEAGLE

COPY ./package /opt/SWEAGLE/

RUN chown -R sweagle:sweagle /opt/SWEAGLE

USER sweagle
WORKDIR /opt/SWEAGLE/bin/taskRunner
CMD ["java","-jar","task-runner-1.0.0.jar"]
EXPOSE 8082
