FROM docker.elastic.co/elasticsearch/elasticsearch:6.8.6

USER root
RUN rm -f /usr/share/elasticsearch/config/elasticsearch.yml
COPY ./conf/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
#COPY ./conf/jvm.options /usr/share/elasticsearch/config/jvm.options
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config

USER elasticsearch
EXPOSE 9200
EXPOSE 9300
