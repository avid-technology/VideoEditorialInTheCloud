# Core Collection

## Introduction

This collection will help you deploy 1 resource group and 1 domain controller. 

A basic network will be built in the resource group with 1 Vnet and 7 subnets: 

- subnet_core
- subnet_mediacentral
- subnet_monitor
- subnet_remote
- subnet_storage
- subnet_transfer
- subnet_workstations

![current + Next Version](./Network.png)

2 default NSG will be created: 

- nsg-remote
- nsg_default

To promote the server to be a domain controller, follow the link below: 

- Promote server to [Domain Controller](https://computingforgeeks.com/how-to-install-active-directory-domain-services-in-windows-server/)

## Variables

### Core Module

- vnet_name
- resource_group_name
- resource_group_location
- address_space
- dns_servers
- create_subnet_Mediacentral
- create_subnet_Monitor
- create_subnet_Remote
- create_subnet_Storage
- create_subnet_Transfer
- create_subnet_Workstations 
- subnets                       
- tags

### Domain Controller Module

- local_admin_username              
- local_admin_password             
- resource_group_name          
- resource_group_location         
- vnet_name                       
- subnet_name                     
- script_url                  
- installers_url              
- domaincontroller_vm_size        
- domaincontroller_vm_hostname    
- domaincontroller_nb_instances 
- domaincontroller_internet_access