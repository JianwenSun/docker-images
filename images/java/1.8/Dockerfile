FROM centos:7.2.1511

MAINTAINER sunjw

# https://github.com/Yelp/dumb-init
RUN curl -fLsS -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.2/dumb-init_1.0.2_amd64 && chmod +x /usr/local/bin/dumb-init

RUN yum install -y java-1.8.0-openjdk-headless tar
RUN yum clean all
