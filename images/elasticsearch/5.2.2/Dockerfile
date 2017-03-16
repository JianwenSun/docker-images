FROM java:1.8

MAINTAINER sunjw

ENV ELASTICSEARCH_VERSION="5.2.2"

ARG DISTRO_NAME=elasticsearch-$ELASTICSEARCH_VERSION

ENV ELASTICSEARCH_USER=elasticsearch \
    ELASTICSEARCH_HOME=/${DISTRO_NAME}

COPY $DISTRO_NAME.tar.gz /

RUN set -x \
        && tar -xzvf $DISTRO_NAME.tar.gz \
        && rm -r $DISTRO_NAME.tar.gz

RUN set -x \ 
	&& groupadd elasticsearch \
	&& useradd elasticsearch -g elasticsearch -p elasticsearch \
	&& chown -R elasticsearch:elasticsearch $DISTRO_NAME

WORKDIR $DISTRO_NAME

VOLUME ["/elasticsearch"]

EXPOSE 9200 9300

ADD startpoint.sh /startpoint.sh
RUN chmod a+x /startpoint.sh

CMD ["/startpoint.sh"]
