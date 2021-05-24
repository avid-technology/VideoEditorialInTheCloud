# Editorial In The Cloud - Ansible

## Introduction

This repository contains roles to configure resources previously built through Terraform. 

You can build an ansible controller manually and download those roles in it. Or you can take a look at the code inside Terraform Core collection and build an ansible controller which will automatically download all the roles from an Avid Azure storage account. Please contact Avid to get a token to this storage account. 

Find below a list of roles available in this repository: 

- cac_v2021.03-85: install and configure Teradici CAC server.
- cam_v2021.03: install and configure Teradici CAM Standalone server.
- cloud_nexis_client_v2021.3.1: install Cloud Nexis in a Centos system.
- cloud_nexis_system_director_v2021.3.1: install, license and configure a Cloud Nexis.
- cloudux_v2020.9.0: install and configure MediaCentral Cloud UX.
- domain_controller_v0.1.0: configure a standalone domain controller.
- jumpbox_v0.1.0: configure a jumpbox to access your resource group externally.
- mediacomposer_v2021.3.0: install MediaComposer on an Azure NV series.
- zabbix_v0.1.0: install and configure Zabbix to monitor your resource group. 

