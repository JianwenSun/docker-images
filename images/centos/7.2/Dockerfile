FROM scratch
MAINTAINER sunjw
ADD centos-7.2.1511-docker.tar.xz /

LABEL name="CentOS Base Image" \
    vendor="CentOS" \
    license="GPLv2" \
    build-date="20161213"

RUN yum -y install \
		vim \
		openssh-server \
		passwd \
	&& yum clean all

#VOLUME /sys/fs/cgroup /run /tmp
#ENV container=docker

RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh

RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ADD id_rsa.pub /root/.ssh
RUN cat /root/.ssh/id_rsa.pub | xargs echo >> /root/.ssh/authorized_keys

EXPOSE 22

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
	&& ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
	&& ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' 

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
