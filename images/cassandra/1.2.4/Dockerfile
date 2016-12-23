FROM java:1.8

MAINTAINER sunjw

ENV CASSANDRA_VERSION="1.2.4"

ARG DISTRO_NAME=apache-cassandra-$CASSANDRA_VERSION

ENV CASSANDRA_USER=cassandra \
    CASSANDRA_HOME=/${DISTRO_NAME}

COPY $DISTRO_NAME.tar.gz /

RUN set -x \
        && tar -xzvf $DISTRO_NAME.tar.gz \
        && rm -r $DISTRO_NAME.tar.gz

WORKDIR $DISTRO_NAME

VOLUME ["/cassandra"]

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

ADD startpoint.sh /startpoint.sh
RUN chmod a+x /startpoint.sh

CMD ["/startpoint.sh"]
