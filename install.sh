#!/bin/sh
apk update &&\
apk add -q -u -f -l vim wget curl git openssh-server openssh-client bash &&\
apk fetch && apk upgrade
sleep 10
#ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -P  -q
ssh-keyscan github.com >> githubKey
ssh-keyscan gitlab.com >> githubKey
ssh-keygen -lf githubKey
cat githubKey > /root/.ssh/known_hosts
chmod 600 /root/.ssh/*
echo "=================================================="
echo "Please add this key to your gitlab/github account"
echo "=================================================="
echo "===SSH=PUBLIC=KEY:================================"
cat /root/.ssh/id_rsa.pub
echo "=================================================="
