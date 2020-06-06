FROM oracle/graalvm-ce:20.0.0
RUN gu install native-image
RUN gu install python
#RUN gu rebuild-images python native-image

RUN useradd -r sweagle && \
    mkdir -p /opt/SWEAGLE

COPY ./package /opt/SWEAGLE

RUN chmod +x /opt/SWEAGLE/scripts/*.sh && \
    chown -R sweagle:sweagle /opt/SWEAGLE

USER sweagle

#WORKDIR /opt/SWEAGLE/bin/scriptExecutor
CMD [ "/opt/SWEAGLE/scripts/startScriptExecutor.sh" ]
EXPOSE 8083
