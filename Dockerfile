FROM alpine:latest

ENV RESTART_POLICY="yes"\
 GIT_USER="fabrizio.torelli"\
 GIT_EMAIL="fabrizio.torelli@optiim.com"

WORKDIR /root

RUN mkdir /root/scripts 

COPY install.sh /root
COPY docker-entrypoint.sh /
COPY clone-repo.sh /root/scripts
COPY run-script.sh /root/scripts
COPY run-command.sh /root/scripts
COPY execute-api-calls.sh /root/scripts
RUN mkdir /root/.ssh
COPY id_rsa /root/.ssh
COPY id_rsa.pub /root/.ssh

RUN dos2unix /root/install.sh &&\
dos2unix /docker-entrypoint.sh &&\
dos2unix /root/scripts/* &&\
 chmod +x /root/install.sh &&\
 chmod +x /docker-entrypoint.sh &&\
 chmod +x /root/scripts/* &&\
 /root/install.sh &&\
 rm -f /root/install.sh &&\
 mkdir -p /mnt/disk &&\
 mkdir -p /root/repo
 
VOLUME /mnt/disk
 
ENTRYPOINT ["/docker-entrypoint.sh"]

 
