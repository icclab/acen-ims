Project Clearwater Heat Orchestration Templates
===============================================

## OpenStack

An OpenStack template which orchestrates Project Clearwater components on OpenStack cloud (with Neutron) using standard OpenStack HEAT resources.

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

After providing input properties create a Clearwater stack:

```
heat stack-create -f ./templates/clearwater-openstack.yaml clearwater
```

## CloudStack

A CloudStack template which orchestrates Project Clearwater components on CloudStack cloud (with advanced networking) using resources defined in [CloudStack HEAT plugin](https://github.com/icclab/cloudstack-heat).

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

After providing input properties create a Clearwater stack:

```
heat stack-create -f ./templates/clearwater-cloudstack.yaml clearwater
```

## Acknowledgment
This work was made possible by the [KTI ACEN project](http://blog.zhaw.ch/icclab/acen-begins/) in collaboration with [Citrix](https://www.citrix.com/) and [Exoscale](https://www.exoscale.ch/).
