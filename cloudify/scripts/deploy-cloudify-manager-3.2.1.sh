#!/bin/bash

#############################################
# Script deploying Cloudify Manager 3.2.1
# Tested on Ubuntu 14.04 server
#############################################

# Machine's public IP
PUBLIC_IP=
# Machine's private IP
PRIVATE_IP=

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
cfy init
wget https://github.com/cloudify-cosmo/cloudify-manager-blueprints/archive/3.2.1.tar.gz
tar -xzf 3.2.1.tar.gz
cat <<EOF > ./cloudify-manager-blueprints-3.2.1/simple/inputs.yaml
public_ip: '$PUBLIC_IP'
private_ip: '$PRIVATE_IP'
ssh_user: 'root'
ssh_key_filename: '/root/.ssh/id_rsa.pub'
agents_user: ubuntu
resources_prefix: ''
EOF
cfy bootstrap --install-plugins -p ./cloudify-manager-blueprints-3.2.1/simple/simple-manager-blueprint.yaml -i ./cloudify-manager-blueprints-3.2.1/simple/inputs.yaml
cfy status
