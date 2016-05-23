Project Clearwater Cloudify blueprints
======================================

A blueprint which orchestrates Project Clearwater on CloudStack cloud using Cloudify CloudStack plugin and Fabric.

`./blueprints/clearwater_cloudstack_simple.yaml`

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

## Acknowledgment
This work was made possible by the [KTI ACEN project](http://blog.zhaw.ch/icclab/acen-begins/) in collaboration with [Citrix](https://www.citrix.com/) and [Exoscale](https://www.exoscale.ch/).