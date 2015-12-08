#!/bin/bash

#############################################
# Script deploying Cloudify 3.2.1 using virtualenv
# Tested on Ubuntu 14.04 server
#############################################

echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt-get -y update
apt-get -y install python-dev python-pip
ssh-keygen -f /root/.ssh/id_rsa -N ""
cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
pip install virtualenv
virtualenv cfy-3.2.1
cd cfy-3.2.1
source ./bin/activate
pip install cloudify==3.2.1
