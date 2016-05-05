#!/bin/bash

# Temporary DNS settings
echo "nameserver 8.8.8.8" > /etc/resolv.conf

mkdir -p /home/ubuntu/.ssh/

# Inject public SSH keys
echo $public_ssh_key >> /home/ubuntu/.ssh/authorized_keys