curl -v -X PUT http://localhost:8051/orchestrator/default \
-H 'Content-Type: text/occi' \
-H 'Category: orchestrator; scheme="http://schemas.mobile-cloud-networking.eu/occi/service#"' \
-H 'X-Auth-Token: '$KID \
-H 'X-Tenant-Name: '$TENANT \
-H 'X-OCCI-Attribute: acen.ims.platform="exoscale"' \
-H 'X-OCCI-Attribute: acen.ims.region="CloudStack"' \
-H 'X-OCCI-Attribute: acen.ims.dns_zone="example.com"' \
-H 'X-OCCI-Attribute: acen.ims.dns_key="zPDgJ0y0AEmCP7fzCi93zfBRYRcYdDDv5xrmwyv7rLgzqSnBlT8n0o1mrHTNpety1QUK55+nBKAedcRluAW39w=="' \
-H 'X-OCCI-Attribute: acen.ims.signup_key="mvPC5Zza"'
