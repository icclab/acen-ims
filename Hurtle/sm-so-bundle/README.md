IMSaaS Hurtle SO-SM bundle
==========================

Deploys and provisions Project Clearwater as-a-service.

Structure:

 * `./wsgi` contains WSGI application and SO implementation.
 * `./data` contains Heat orchestration templates (HOTs) describing infrastructural graph and basic scripts for initial resource setup.

## RUN SM locally

```DESIGN_URI=http://keystone_url:35357/v2.0 OPENSHIFT_REPO_DIR=$PWD python ./wsgi/application```

## Service Attributes

Service instance configuration must be provided in the headers of the init PUT HTTP request.

Service instance requires following attributes:

 * `acen.ims.platform`
 * `acen.ims.region`
 * `acen.ims.dns_zone`
 * `acen.ims.dns_key`
 * `acen.ims.signup_key`

which are specified in the header as follows:

```-H 'X-OCCI-Attribute: ATRIBUTE_NAME="ATTRIBUTE_VALUE"'```

e.g.:

```-H 'X-OCCI-Attribute: acen.ims.region="CloudStack"'```

Currently on CloudStack platforms are supported. Note that orchestration of CloudStack resources is not supported by Heat nativly. To change that, please install and configure [Heat CloudStack plugin](https://github.com/icclab/cloudstack-heat). Also note that platform values must be one of the following values: `os` for OpenStack regions and `cs`for CloudStack regions.

Regions must be valid OpenStack regions in your deployment. Always make sure that specified region and platform don't colide.

Other cloud environment specific values needs to be modified accordinglyto match your deployment in provided infrastructural templates.

## Sample requests

Before issuing following requests set `KID` and `TENANT` environment variables accordingly:
 * `KID` - Keystone token ID.
 * `TENANT` - Tenant name.

Initialize the SO:

    $curl -v -X PUT http://localhost:8051/orchestrator/default \
        -H 'Content-Type: text/occi' \
        -H 'Category: orchestrator; scheme="http://schemas.mobile-cloud-networking.eu/occi/service#"' \
        -H 'X-Auth-Token: '$KID \
        -H 'X-Tenant-Name: '$TENANT \
        -H 'X-OCCI-Attribute: acen.ims.platform="cs"' \
        -H 'X-OCCI-Attribute: acen.ims.region="CloudStack"' \
        -H 'X-OCCI-Attribute: acen.ims.dns_zone="example.com"' \
        -H 'X-OCCI-Attribute: acen.ims.dns_key="zPDgJ0y0AEmCP7fzCi93zfBRYRcYdDDv5xrmwyv7rLgzqSnBlT8n0o1mrHTNpety1QUK55+nBKAedcRluAW39w=="' \
        -H 'X-OCCI-Attribute: acen.ims.signup_key="mvPC5Zza"'

Get state of the SO + service instance:

    $ curl -v -X GET http://localhost:8051/orchestrator/default \
          -H 'X-Auth-Token: '$KID \
          -H 'X-Tenant-Name: '$TENANT

Trigger deployment of the service instance:

    $ curl -v -X POST http://localhost:8051/orchestrator/default?action=deploy \
          -H 'Content-Type: text/occi' \
          -H 'Category: deploy; scheme="http://schemas.mobile-cloud-networking.eu/occi/service#"' \
          -H 'X-Auth-Token: '$KID \
          -H 'X-Tenant-Name: '$TENANT

Trigger provisioning of the service instance:

    $ curl -v -X POST http://localhost:8051/orchestrator/default?action=provision \
          -H 'Content-Type: text/occi' \
          -H 'Category: provision; scheme="http://schemas.mobile-cloud-networking.eu/occi/service#"' \
          -H 'X-Auth-Token: '$KID \
          -H 'X-Tenant-Name: '$TENANT

Trigger delete of SO + service instance:

    $ curl -v -X DELETE http://localhost:8051/orchestrator/default \
          -H 'X-Auth-Token: '$KID \
          -H 'X-Tenant-Name: '$TENANT

## Acknowledgment
This work was made possible by the [KTI ACEN project](http://blog.zhaw.ch/icclab/acen-begins/) in collaboration with [Citrix](https://www.citrix.com/) and [Exoscale](https://www.exoscale.ch/).