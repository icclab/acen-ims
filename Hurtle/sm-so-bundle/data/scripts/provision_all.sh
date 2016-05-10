#!/bin/bash

# Input parameters:
#   $local_ip: { get_attr: [ralf_port, fixed_ips, 0, ip_address] }
#   $public_ip: { get_attr: [ralf_floating_ip, floating_ip_address] }
#   $ralf_local_ip: { get_attr: [ralf_port, fixed_ips, 0, ip_address] }
#   $homer_local_ip: { get_attr: [homer_port, fixed_ips, 0, ip_address] }
#   $ellis_local_ip: { get_attr: [ellis_port, fixed_ips, 0, ip_address] }
#   $bono_local_ip: { get_attr: [bono_port, fixed_ips, 0, ip_address] }
#   $sprout_local_ip: { get_attr: [sprout_port, fixed_ips, 0, ip_address] }
#   $homestead_local_ip: { get_attr: [homestead_port, fixed_ips, 0, ip_address] }
#   $zone: { get_param: zone }
#   $dnssec_key: { get_param: dnssec_key }
#   $dns_ip: { get_attr: [dns_floating_ip, floating_ip_address] }
#   $hostname: 'ralf'
#   $signup_key: 'mvPC5Zza'

# Add Project Clearwater repo and update repo list
mkdir -p /etc/apt/sources.list.d/
touch /etc/apt/sources.list.d/clearwater.list
echo "deb http://repo.cw-ngv.com/latest binary/" > /etc/apt/sources.list.d/clearwater.list
curl -L http://repo.cw-ngv.com/repo_key | sudo apt-key add -
apt-get update

# Persistent DNS settings
DEBIAN_FRONTEND=noninteractive apt-get install dnsmasq --yes --force-yes
cat <<EOF > /etc/dnsmasq.resolv.conf
nameserver $dns_ip
nameserver 8.8.8.8
EOF
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' >> /etc/default/dnsmasq
service dnsmasq force-reload

# Clearwater local config
mkdir -p /etc/clearwater/
touch /etc/clearwater/local_config
cat <<EOF > /etc/clearwater/local_config
local_ip=$local_ip
public_ip=$public_ip
public_hostname=$hostname.$zone
etcd_cluster=$ralf_local_ip,$homer_local_ip,$ellis_local_ip,$sprout_local_ip,$bono_local_ip,$homestead_local_ip
EOF

# Clearwater shared config
touch /etc/clearwater/shared_config
cat <<EOF > /etc/clearwater/shared_config
# Deployment definitions
home_domain=$zone
sprout_hostname=sprout.$zone
hs_hostname=homestead.$zone:8888
hs_provisioning_hostname=homestead.$zone:8889
ralf_hostname=ralf.$zone:10888
xdms_hostname=homer.$zone:7888

# Email server configuration
smtp_smarthost=localhost
smtp_username=username
smtp_password=password
email_recovery_sender=clearwater@$zone

# Keys
signup_key=$signup_key
turn_workaround=$signup_key
ellis_api_key=$signup_key
ellis_cookie_key=$signup_key
EOF

# Chronos config
if [[ $hostname == 'ralf' || $hostname == 'sprout' ]]; then
mkdir -p /etc/chronos/
touch /etc/chronos/chronos.conf
cat <<EOF > /etc/chronos/chronos.conf
[http]
bind-address = $local_ip
bind-port = 7253
threads = 50
[logging]
folder = /var/log/chronos
level = 2
[alarms]
enabled = true
[exceptions]
max_ttl = 600
EOF
fi

# Node specific configuration
case $hostname in
  ralf)
    DEBIAN_FRONTEND=noninteractive apt-get install ralf --yes --force-yes -o DPkg::options::=--force-confnew
    DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
    ;;
  ellis)
    DEBIAN_FRONTEND=noninteractive apt-get install ellis --yes --force-yes -o DPkg::options::=--force-confnew
    DEBIAN_FRONTEND=noninteractive apt-get install clearwater-config-manager --yes --force-yes
    sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' /etc/nginx/nginx.conf
    service nginx restart
    ;;
  homer)
    DEBIAN_FRONTEND=noninteractive apt-get install clearwater-cassandra --yes --force-yes -o DPkg::options::=--force-confnew
    DEBIAN_FRONTEND=noninteractive apt-get install homer --yes --force-yes -o DPkg::options::=--force-confnew
    DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
    ;;
  sprout)
    DEBIAN_FRONTEND=noninteractive apt-get install sprout --yes --force-yes -o DPkg::options::=--force-confnew
    DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
    ;;
  homestead)
    DEBIAN_FRONTEND=noninteractive apt-get install clearwater-cassandra --yes --force-yes -o DPkg::options::=--force-confnew
    DEBIAN_FRONTEND=noninteractive apt-get install homestead homestead-prov --yes --force-yes -o DPkg::options::=--force-confnew
    DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
    ;;
  bono)
    DEBIAN_FRONTEND=noninteractive apt-get install bono --yes --force-yes -o DPkg::options::=--force-confnew
    DEBIAN_FRONTEND=noninteractive apt-get install clearwater-config-manager --yes --force-yes
    ;;
esac

# Ellis generates numbers
if [[ $hostname == 'ellis' ]]; then
/usr/share/clearwater/ellis/env/bin/python /usr/share/clearwater/ellis/src/metaswitch/ellis/tools/create_numbers.py --start 666000000 --count 1000
fi

# Update DNS server
if [[ $hostname == 'ellis' || $hostname == 'homer' || $hostname == 'homestead' || $hostname == 'ralf' ]]; then
retries=0
while ! { nsupdate -y "$zone:$dnssec_key" -v << EOF
zone $zone
server $dns_ip
update add $hostname.$zone. 30 A $public_ip
send
EOF
} && [ $retries -lt 10 ]
do
  retries=$((retries + 1))
  echo 'nsupdate failed - retrying (retry '$retries')...'
  sleep 10
done
fi

if [[ $hostname == 'bono' ]]; then
retries=0
while ! { nsupdate -y "$zone:$dnssec_key" -v << EOF
zone $zone
server $dns_ip
update add $hostname.$zone. 30 A $public_ip
update add $zone. 30 A $public_ip
update add $zone. 30 NAPTR 0 0 "s" "SIP+D2T" "" _sip._tcp.$zone.
update add $zone. 30 NAPTR 0 0 "s" "SIP+D2U" "" _sip._udp.$zone.
update add _sip._tcp.$zone. 30 SRV 0 0 5060 bono.$zone.
update add _sip._udp.$zone. 30 SRV 0 0 5060 bono.$zone.
send
EOF
} && [ $retries -lt 10 ]
do
  retries=$((retries + 1))
  echo 'nsupdate failed - retrying (retry '$retries')...'
  sleep 10
done
fi

if [[ $hostname == 'sprout' ]]; then
retries=0
while ! { nsupdate -y "$zone:$dnssec_key" -v << EOF
server $dns_ip
update add $hostname.$zone. 30 A $public_ip
update add scscf.$hostname.$zone. 30 A $public_ip
update add icscf.$hostname.$zone. 30 A $public_ip
update add $hostname.$zone. 30 NAPTR 0 0 "s" "SIP+D2T" "" _sip._tcp.$hostname.$zone.
update add _sip._tcp.$hostname.$zone. 30 SRV 0 0 5054 $hostname.$zone.
update add icscf.$hostname.$zone. 30 NAPTR 0 0 "s" "SIP+D2T" "" _sip._tcp.icscf.$hostname.$zone.
update add _sip._tcp.icscf.$hostname.$zone. 30 SRV 0 0 5052 $hostname.$zone.
update add scscf.$hostname.$zone. 30 NAPTR 0 0 "s" "SIP+D2T" "" _sip._tcp.scscf.$hostname.$zone.
update add _sip._tcp.scscf.$hostname.$zone. 30 SRV 0 0 5054 $hostname.$zone.
send
EOF
} && [ $retries -lt 10 ]
do
retries=$((retries + 1))
echo 'nsupdate failed - retrying (retry '$retries')...'
sleep 5
done
fi

echo 'nameserver $dns_ip' > /etc/dnsmasq.resolv.conf
service dnsmasq force-reload