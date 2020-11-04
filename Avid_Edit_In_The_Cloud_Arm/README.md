# Abstract

This readme file explains the value of video editorial in the cloud using Avid Media Composer and Avid Nexis on Microsoft Azure. The deployment guide included in this repository explains, step-by-step, how to deploy these applications into your Azure subscription.  The deployment guide and accompanying scripts are designed for media production companies that want to provide an edit-on-demand deployment experience.

# Deployment Architecture 

<img src="./diagram2.PNG" />

# Prerequisite

- Resource Prefix: 3 to 4 letters.

- Active enterprise or pay-as-you-go Azure subscription.

- License for: a) Avid NEXIS | Cloud, b) Avid Media Composer Ultimate with VM Option, c) Signiant MediaShuttle, Aspera HSTS, FileCatalyst Server, d) Teradici Graphics Agent.

# Deploy to Azure

To perform a successful deployment in your subscription, follow the steps below: 

1) Deploy each module needed. 

2) Follow the deployment guide to finish each module configuration.  

## Module deployment

1) [Optional] Create Resource Group within your subscription directly within Azure Portal.

<br />

2) [Optional] If you don’t have a Vnet yet, create one Vnet (with at least one subnet) directly within Azure Portal using the link below:

<br />

| Module | Compatible Version | ARM Template link |
| ------ | ------------------ | ----------------- |
| Vnet | n/a | <a href="https://portal.azure.com/#create/Microsoft.VirtualNetwork-ARM" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" /></a> |

<br />

3) Choose a file transfer accelerator module: Signiant, FileCatalyst or Aspera

<br />

| Module | Compatible Version | ARM Template link |
| ------ | ------------------ | ----------------- |
| Signiant | Signiant 3.3.2 <br /> Nexis 20.7.3.10 (Client) | <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Favid-technology%2FVideoEditorialInTheCloud%2Fmaster%2FAvid_Edit_In_The_Cloud_Arm%2Fsigniant%2Fsigniantazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" /></a> |
| FileCatalyst | FileCatalyst 3.7.3b38 <br /> Nexis 20.7.3.10 (Client) | <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Favid-technology%2FVideoEditorialInTheCloud%2Fmaster%2FAvid_Edit_In_The_Cloud_Arm%2Ffilecatalyst%2Ffilecatalystazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" /></a> |
| Aspera | Aspera 3.9.6 <br /> Nexis 20.7.3.10 (Client) | <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Favid-technology%2FVideoEditorialInTheCloud%2Fmaster%2FAvid_Edit_In_The_Cloud_Arm%2Faspera%2Fasperaazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" /></a> |

<br />

4) Choose a Media Composer module depending on the version and GPU selected.

<br />

| Module | Compatible Version | ARM Template link |
| ------ | ------------------ | ----------------- |
| Media Composer | Media Composer 2018.12.13  / 2019.12 / 2020.9.0 <br /> Nexis 20.7.3.10 (Client) <br /> Teradici Agent 20.10.1 <br /> Amd GPU <br /> Nvidia GPU | <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Favid-technology%2FVideoEditorialInTheCloud%2Fmaster%2FAvid_Edit_In_The_Cloud_Arm%2Fmediacomposer%2Fmediacomposerazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" /></a> |

<br />

To duplicate the VM, follow the steps below:
<br />

a) Create a snapshot of the main os disk
<br />

b) Run script to duplicate snapshot x time (right click / run in powershell connected to your azure subscription)
<br />

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Favid-technology%2FVideoEditorialInTheCloud%2Fmaster%2FAvid_Edit_In_The_Cloud_Arm%2Fscripts%2Fcreate_disk_from_snapshot.ps1" target="_blank"></a>

c) Use duplication ARM template: 
<br />

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Favid-technology%2FVideoEditorialInTheCloud%2Fmaster%2FAvid_Edit_In_The_Cloud_Arm%2Fmediacomposer%2Fmediacomposercloning.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" /></a>

<br />

5) Deploy a Nexis storage module.

<br />

| Module | Compatible Version | ARM Template link |
| ------ | ------------------ | ----------------- |
| Nexis | Avid Cloud Nexis 20.7.0 | <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Favid-technology%2FVideoEditorialInTheCloud%2Fmaster%2FAvid_Edit_In_The_Cloud_Arm%2Fmediacomposer%2Fmediacomposercloning.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" /></a> |

<br />

## Module configuration

Once you are done with each module deployment, finish the installation using the deployment guide: 

[Az Cli deployment](https://github.com/avid-technology/VideoEditorialInTheCloud/blob/master/Avid_Edit_In_The_Cloud_Arm/Document/Deployment_Guide_2020.pdf) 