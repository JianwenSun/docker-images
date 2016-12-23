FROM java:1.8

MAINTAINER sunjw

ARG DISTRO_NAME=kafka_2.11-0.10.1.0

ENV KAFKA_USER=kafka \
	KAFKA_VERSION="0.10.1.0" \
	SCALA_VERSION="2.11" \
	KAFKA_HOME=/${DISTRO_NAME} \
    KAFKA_PORT=9092

ARG DISTRO_NAME=kafka_2.11-0.10.1.0

COPY $DISTRO_NAME.tgz /

RUN set -x \
        && tar -xzvf $DISTRO_NAME.tgz \
        && rm -r $DISTRO_NAME.tgz

#RUN set -x \
#        && yum install -y wget \
#        && wget "http://apache.fayea.com/kafka/${KAFKA_VERSION}/${DISTRO_NAME}.tgz" \
#        && tar -xzvf "${DISTRO_NAME}.tgz" \
#        && rm -r "${DISTRO_NAME}.tgz"

WORKDIR $DISTRO_NAME

VOLUME ["/kafka"]

EXPOSE $KAFKA_PORT 9099

ADD startpoint.sh /
RUN chmod a+x /startpoint.sh

CMD ["/startpoint.sh"]
