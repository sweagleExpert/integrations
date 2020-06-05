FROM openjdk:8-jdk-alpine
RUN apk add --no-cache bash
RUN apk add --no-cache gcompat

RUN addgroup sweagle && \
    adduser -S -G sweagle sweagle && \
		mkdir -p /opt/SWEAGLE

COPY ./package /opt/SWEAGLE

RUN chown -R sweagle:sweagle /opt/SWEAGLE && \
    chmod +x /opt/SWEAGLE/scripts/*.sh

USER sweagle
WORKDIR /opt/SWEAGLE/bin/ml
CMD [ "/opt/SWEAGLE/scripts/startML.sh" ]
EXPOSE 8084
