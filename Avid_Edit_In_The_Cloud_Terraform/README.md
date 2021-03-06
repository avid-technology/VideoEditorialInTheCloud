# Editorial In The Cloud - Terraform

## Introduction

This repository demonstrates how to deploy an *Editorial In The Cloud* environment based on Avid technology and partners via Terraform. This is a Proof of Concept based on a specific network. You will certainly have a different network architecture and should adapt each module to your specific environment. 

Avid will not be accountable for environment taken to production based on this repository. You should work with your own security team to make sure all module deployed follows your specific network rules and best practice. 

 Modules are grouped together by collection: 

- [**Core**](https://github.com/avid-technology/VideoEditorialInTheCloud/tree/master/Avid_Edit_In_The_Cloud_Terraform/Core): Resource Group, Network, Domain Controller.
- [**Mediacentral**](https://github.com/avid-technology/VideoEditorialInTheCloud/tree/master/Avid_Edit_In_The_Cloud_Terraform/Mediacentral): Asset Management, Cloud UX.
- [**Monitor**](https://github.com/avid-technology/VideoEditorialInTheCloud/tree/master/Avid_Edit_In_The_Cloud_Terraform/Monitor): Zabbix.
- [**Remote**](https://github.com/avid-technology/VideoEditorialInTheCloud/tree/master/Avid_Edit_In_The_Cloud_Terraform/Remote): Jumpbox, Teradici CAC.
- [**Transfer**](https://github.com/avid-technology/VideoEditorialInTheCloud/tree/master/Avid_Edit_In_The_Cloud_Terraform/Transfer): FileCatalyst, Aspera, Signiant.
- [**Storage**](https://github.com/avid-technology/VideoEditorialInTheCloud/tree/master/Avid_Edit_In_The_Cloud_Terraform/Storage): Nexis.
- [**Workstations**](https://github.com/avid-technology/VideoEditorialInTheCloud/tree/master/Avid_Edit_In_The_Cloud_Terraform/Workstations): MediaComposer, ProTools.

Each module contains a Readme document to explain what the collection can build.

For the proof of concept, we will deploy the following network in this order: 1) Core 2) Remote 3) Storage 4) Workstations 5) Transfer 6) MediaCentral 7) Monitor. Feel free to bypass a collection creation if you do not need it in your own environment. 

![current + Next Version](./network.png)

## Prerequisite

There is a dockerfile at the root of this repository to let you run this code in a container. It has been tested with Docker Desktop version 3.22 (Docker Engine 20.10.5). 

If you decide not to run this code in a container, make sure you have the following tool and version: 

- Terraform >= 0.14.4
- Azure CLI >= 2.17.1
- Ansible >= 2.9.6
- Packer >= 1.6.6
- Azurerm >= 2.26

## Installation 

1. Clone entire repository: *$git clone https://github.com/avid-technology/VideoEditorialInTheCloud.git*
1. Go to Core collection [Readme](https://github.com/avid-technology/VideoEditorialInTheCloud/tree/master/Avid_Edit_In_The_Cloud_Terraform/Core) to install the first collection.

## Additional documentaiton

- Azure [learning paths](https://docs.microsoft.com/en-us/learn/azure/)
- Introduction to Terraform on Azure: [Terraform](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code?in=terraform/aws-get-started)

## Maintainer

For any information or to report bug and security issue, feel free to contact benjamin.ghis@avid.com 



