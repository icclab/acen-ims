#!/bin/bash

# Input parameters:
#   $zone: { get_param: zone }
#   $dnssec_key: { get_param: dnssec_key }
#   $public_ip: { get_attr: [ dns_floating_ip, floating_ip_address ] }

# Redirects output to the file
#exec > >(tee -a /var/log/clearwater-heat.log) 2>&1
#curl -XPOST $LOGGER --data "dns provisioning started"

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

cat <<EOF > /etc/bind/named.conf.options
options {
  directory "/var/cache/bind";
  allow-recursion { any; };
  allow-query { any; };
  allow-query-cache { any; };
  forwarders {
    8.8.8.8;
  };
  forward only;
  dnssec-validation no;
  auth-nxdomain no;    # conform to RFC1035
  listen-on-v6 { any; };
};
EOF

# Create basic zone config
cat <<EOF > /var/lib/bind/db.$zone
__DOLLAR_SIGN__ORIGIN $zone.
__DOLLAR_SIGN__TTL 1h
@ IN SOA ns admin@$zone. ( $(date +%Y%m%d%H) 1d 2h 1w 30s )
@ NS ns
ns A $public_ip
EOF

sed -i.bckp s/__DOLLAR_SIGN__/\$/g /var/lib/bind/db.$zone

chown root:bind /var/lib/bind/db.$zone

service bind9 reload
