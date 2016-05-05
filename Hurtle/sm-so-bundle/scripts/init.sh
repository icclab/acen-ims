curl -v -X PUT http://localhost:8051/orchestrator/default \
-H 'Content-Type: text/occi' \
-H 'Category: orchestrator; scheme="http://schemas.mobile-cloud-networking.eu/occi/service#"' \
-H 'X-Auth-Token: '$KID \
-H 'X-Tenant-Name: '$TENANT
