#!/bin/bash

# Input parameters:
#   $zone: { get_param: zone }
#   $dnssec_key: { get_param: dnssec_key }
#   $public_ip: { get_attr: [ dns_floating_ip, floating_ip_address ] }
#   $public_ssh_key: { get_param: public_ssh_key }

# Redirects output to the file
exec > >(tee -a /var/log/clearwater-heat.log) 2>&1

# Temporary DNS settings
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

# Inject public SSH key
echo $public_ssh_key >> /root/.ssh/authorized_keys

# Update repo list
apt-get update

# Install bind9
DEBIAN_FRONTEND=noninteractive apt-get install bind9 --yes --force-yes

# Update bind configuration
cat <<EOF >> /etc/bind/named.conf.local
key $zone. {
  algorithm "HMAC-MD5";
  secret "$dnssec_key";
};

zone "$zone" IN {
  type master;
  file "/var/lib/bind/db.$zone";
  allow-update {
    key $zone.;
  };
};
EOF

# Create basic zone config
cat <<EOF > /var/lib/bind/db.$zone
\$ORIGIN $zone.
\$TTL 1h
@ IN SOA ns admin\@$zone. ( $(date +%Y%m%d%H) 1d 2h 1w 30s )
@ NS ns
ns A $public_ip
EOF
chown root:bind /var/lib/bind/db.$zone

service bind9 reload
