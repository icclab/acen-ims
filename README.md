# Apache CloudStack for NFV - IP Multimedia Subsystem (ACEN - IMS)
This repository provides orchestration templates for deploying open source IMS implementation - [Project Clearwater](http://www.projectclearwater.org/).

## Templates for OpenStack HEAT
### OpenStack
 - OpenStack template orchestrates Project Clearwater components on OpenStack cloud (with Neutron) using standard OpenStack HEAT resources.

OpenStack template input properties:
 - Virtual machine properties
   - flavor: OpenStack flavor
   - image: Openstack image (Ubuntu 14.04 - 64bit)
   - public_ssh_key: Public SSH key
   - private_mgmt_net: Internal network ID
   - public_net: Public network id
 - DNS server properties
   - zone: Clearwater DNS zone (default: ims.com)
   - dnssec_key: base64 encoded DNS secret key

After providing input properties create a clearwater stack:

```
heat stack-create -f HEAT/templates/clearwater-openstack.yaml clearwater
```

### CloudStack
 - CloudStack template orchestrates Project Clearwater components on CloudStack cloud (with advanced networking) using resources defined in [CloudStack HEAT plugin](https://github.com/icclab/cloudstack-heat).

CloudStack template input properties:
 - CloudStack authentication properties
   - api_endpoint: CloudStack API endpoint
   - api_key: CloudStack API key
   - api_secret: CloudStack API secret key
 - General properties:
   - zone_id: CloudStack zone ID
 - Virtual machine properties
   - service_offering_id: CloudStack service offering ID
   - template_id: CloudStack template ID (Ubuntu 14.04 - 64bit)
   - public_ssh_key: Public SSH key
 - Clearwater network properties
   - network_offering_id: CloudStack network offering ID
   - gateway: Clearwater network gateway (within VPC CIDR, default: 10.0.0.1)
   - netmask: Clearwater network netmask (default: 255.255.255.0)
   - vpc_id: CloudStack VPC ID
   - acl_id: ACL to be used for the Clearwater network
 - DNS server properties
   - dns_zone: Clearwater DNS zone (default: ims.com)
   - dnssec_key: base64 encoded DNS secret key

After providing input properties create a clearwater stack:

```
heat stack-create -f HEAT/templates/clearwater-cloudstack.yaml clearwater
```

## Cloudify blueprints
`./cloudify/blueprints/clearwater_cloudstack_simple.yaml`

 - Blueprint deploying Project Clearwater on CloudStack cloud using Cloudify CloudStack plugin and Fabric.

Blueprint input properties:
 - cs_api_key: CloudStack API key
 - cs_api_secret: CloudStack API secret key
 - cs_api_url: CloudStack API endpoint
 - image_id: CloudStack template ID (Ubuntu 14.04 - 64bit)
 - size_id: CloudStack service offering ID
 - key_name: SSH keypair name
 - zone: CloudStack zone name
 - network_offering: CloudStack network offering name
 - dns_zone: Clearwater DNS zone
 - dnssec_key: Clearwater DNS secret key

Tested with Cloudify 3.2.1 and [modified Cloudify CloudStack plugin 1.2.1](https://github.com/icclab/cloudify-cloudstack-plugin) allowing firewall port range specification.

```
local init --install-plugins -p test_cloudstack.yaml
cfy local execute -w install
```
