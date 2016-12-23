FROM java:1.8

MAINTAINER sunjw

ARG DISTRO_NAME=zookeeper-3.4.9

ENV ZOO_USER=zookeeper \
    ZOO_CONF_DIR=/${DISTRO_NAME}/conf \
    ZOO_DATA_DIR=/zookeeper/data \
	ZOO_BIN_DIR=/${DISTRO_NAME}/bin \
    ZOO_DATA_LOG_DIR=/zookeeper/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2

# Add a user and make dirs
RUN set -x \
    && adduser "$ZOO_USER" \
    && mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" \
    && chown "$ZOO_USER:$ZOO_USER" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"

COPY $DISTRO_NAME.tar.gz /

RUN set -x \
        && tar -xzvf $DISTRO_NAME.tar.gz \
        && rm -r $DISTRO_NAME.tar.gz

# download
# RUN set -x \
#	&& yum install -y wget \
#	&& wget "http://www.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz" \
#	&& yum clean all \
#	&& tar -xzf "$DISTRO_NAME.tar.gz" \
#	&& mv "$DISTRO_NAME/conf/"* "$ZOO_CONF_DIR" \
#	&& rm -r "$DISTRO_NAME.tar.gz"
	
WORKDIR $DISTRO_NAME

VOLUME ["/zookeeper"]

EXPOSE $ZOO_PORT 2888 3888

ADD startpoint.sh /
RUN chmod a+x /startpoint.sh

CMD ["/startpoint.sh"]
