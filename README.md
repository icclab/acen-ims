# Apache CloudStack for NFV - IP Multimedia Subsystem (ACEN - IMS)

This repository provides orchestration templates and deployment scripts for automated deployment of [Project Clearwater](http://www.projectclearwater.org/) on [CloudStack](https://cloudstack.apache.org/). 

Repository structure:

 * [`./HEAT`](./HEAT) contains Heat orchestration templates (HOT) for Clearwater orchestration using [OpenStack Heat](https://wiki.openstack.org/wiki/Heat). 
 * [`./Hurtle`](./Hurtle/sm-so-bundle) contains Hurtle service manager & service orchestrator for Clearwater orchestration using [Hurtle](http://hurtle.it/).
 * [`./cloudify`](./cloudify) contains blueprints for Clearwater orchestration using [Cloudify](http://getcloudify.org/).

Although this work focuses on CloudStack deployments, the `./HEAT` directory also contains an OpenStack version of the orchestration templates.

As Heat (and Hurtle) natively doesn't support orchestration on CloudStack deployments, it is necessary to setup [CloudStack Heat plugin](https://blog.zhaw.ch/icclab/openstack-heat-plugin-for-apache-cloudstack/) to add CloudStack resources.

## Acknowledgment
This work was made possible by the [KTI ACEN project](http://blog.zhaw.ch/icclab/acen-begins/) in collaboration with [Citrix](https://www.citrix.com/) and [Exoscale](https://www.exoscale.ch/).