FROM sunjw/centos:7.2

MAINTAINER jianwenSun

# Some Environment Variables
ENV HOME /root

RUN yum install -y gcc make g++ ruby wget gettext supervisor 
RUN yum install -y python-setuptools \
    && easy_install supervisor

ARG redis_version=3.2.11

RUN wget -qO redis.tar.gz http://download.redis.io/releases/redis-${redis_version}.tar.gz \
    && tar xfz redis.tar.gz -C / \
    && mv /redis-$redis_version /redis

RUN gem install redis -v 3.3.3

RUN (cd /redis && make)

RUN mkdir /redis-conf
RUN mkdir /redis-data

COPY ./docker-data/redis-cluster.tmpl /redis-conf/redis-cluster.tmpl
COPY ./docker-data/redis.tmpl /redis-conf/redis.tmpl

# Add startup script
COPY ./docker-data/startpoint.sh /startpoint.sh

# Add script that generates supervisor conf file based on environment variables
COPY ./docker-data/generate-supervisor-conf.sh /generate-supervisor-conf.sh

RUN chmod 755 /startpoint.sh

EXPOSE 7000 7001 7002 7003 7004 7005 7006 7007

ENTRYPOINT ["/startpoint.sh"]
CMD ["redis-cluster"]
