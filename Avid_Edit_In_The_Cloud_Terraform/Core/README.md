# Core Collection

## Introduction

This collection will help you deploy one resource group and one domain controller. 

A basic network will be built in the resource group with 1 Vnet and 7 subnets: 

- subnet_core
- subnet_mediacentral
- subnet_monitor
- subnet_remote
- subnet_storage
- subnet_transfer
- subnet_workstations

2 default NSG will be created: 

- poc-rg-nsg-remote
- poc-rg-nsg_default

To promote the server to be a domain controller, follow the link below: 

- Promote server to [Domain Controller](https://computingforgeeks.com/how-to-install-active-directory-domain-services-in-windows-server/)