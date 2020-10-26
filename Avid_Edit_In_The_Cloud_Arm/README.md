# Abstract

This readme file explains the value of video editorial in the cloud using Avid Media Composer and Avid Nexis on Microsoft Azure and summarizes key resources in this repository: a deployment guide and deployment scripts. The deployment guide included in this repository explains, step-by-step, how to deploy these applications into your Azure subscription.  The deployment guide and accompanying scripts are designed for media production companies that want to provide an edit-on-demand deployment experience.

# Summary

The cloud will transform how creatives in the Media and Entertainment Industry produce content and collaborate across teams and geographies.  Despite the dramatic potential of the cloud to transform the industry, many creative individuals, teams and companies are not sure how or where to begin their cloud journey.  Microsoft and Avid Technologies have worked jointly on many cloud editorial projects and projects enabling major media companies to migrate their video production workflows to Azure.  We have found the most empowering approach is to learn by doing, ie. Just start experimenting, hands-on, with how Avid on Azure enables cloud-based content production.

The deployment guide and accompanying scripts in this repository enable that hands-on experimentation.  The deployment guide provides step-by-step guidance for installing and configuring a proof of concept environment for you and or your team to immediately deploy and use Avid’s industry leading products – Media Composer and Nexis – for content editing on the Azure Cloud.

# Capabilities of this Solution

Once you have deployed this solution you can

Upload video content to Nexis on Azure

Edit video content using Media Composer on Azure

Back up your video content to Nexis on Azure.

# What is Deployed as part of this Solution

<img src="./diagram.png" />

# Deploy to Azure
<br />

<b> 1) Install Git </b>
<br />

[Install Git](https://git-scm.com/downloads)

<b> 2) Clone project to your local repository. </b>
<br />

PS> git clone https://github.com/avid-technology/VideoEditorialInTheCloud.git

<b> 3) Install Azure CLI / Login to your subscription. </b>
<br />

[Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

PS> az login

<b> 4) Create One Resource Group within your subscription: </b>
<br />

PS> az group create --location xxxx --name xxxx

<i>Example: ps> az group create --location "westus2" --name "myresourcegroup"</i>

<b> 5) Create One Vnet and One subnet within your Resource Group: </b>
<br />

PS> az network vnet create --name xxx --resource-group xxx --address-prefix x.x.x.x/xx --subnet-name xxx --subnet-prefix x.x.x.x/xx

<i>Example: ps> az network vnet create --name "myvnet" --resource-group "myresourcegroup" --address-prefix 10.0.0.0/16 --subnet-name "mysubnet1" --subnet-prefix 10.0.0.0/24</i>

<b> 6) Choose a file transfer accelerator module: </b>
<br />

| Module | Supported Version | Code |
| ------ | ------------------ | ----------------- |
| Signiant | - Signiant SDCX Server v3.3.2 <br /> - Avid NEXIS Client v2020.7.3 | az deployment group create --name xxx --resource-group xxxx --template-file ".\signiant\signiantazuredeploy.json" --parameters "xxxx"  |
| FileCatalyst | - FileCatalyst v3.8.1 <br /> - Avid NEXIS Client v2020.7.3 | az deployment group create --name xxx --resource-group xxxx --template-file ".\filecatalyst\filecatalystazuredeploy.json" --parameters "xxxx" |
| Aspera | - Aspera HSTS v3.9.6 <br /> - Avid NEXIS Client v2020.7.3 | az deployment group create --name xxx --resource-group xxxx --template-file ".\aspera\asperaazuredeploy.json" --parameters "xxxx" |

<i>Example: ps> az deployment group create --name "SigniantTestDeployment" --resource-group "myresourcegroup" --template-file ".\signiant\signiantazuredeploy.json" --parameters ".\signiant\signiant.parameters.json"</i>

<i>Example: ps> az deployment group create --name "FileCatalystTestDeployment" --resource-group "myresourcegroup" --template-file ".\filecatalyst\filecatalystazuredeploy.json" --parameters ".\filecatalyst\filecatalyst.parameters.json"</i>

<i>Example: ps> az deployment group create --name "AsperaTestDeployment" --resource-group "myresourcegroup" --template-file ".\aspera\asperaazuredeploy.json" --parameters ".\aspera\aspera.parameters.json"</i>

<b> 7) Choose a Media Composer module depending on the version and GPU selected. </b>
<br />

| Module | Supported Version | Code |
| ------ | ------------------ | ----------------- |
| Media Composer Nvidia | - Media_Composer 2018.12.11, 2019.12, 2020.4 <br /> - PCoIP Agent 20.04.0 <br /> - Nvidia 442.06 grid <br /> - Avid NEXIS Client v2020.7.3 | az deployment group create --name "xxx" --resource-group "xxxx" --template-file ".\mediacomposer\mediacomposerazuredeploy.json" --parameters "xxxx"  |
| Media Composer AMD | - Media_Composer 2018.12.11, 2019.12, 2020.4 <br /> - PCoIP Agent 20.04.0 <br /> - Radeon-Pro-Software-for-Enterprise-GA.exe <br /> - Avid NEXIS Client v2020.7.3 | az deployment group create --name "xxx" --resource-group "xxxx" --template-file ".\mediacomposer\mediacomposerazuredeploy_AMD.json" --parameters "xxxx" |

<i>Example: ps> az deployment group create --name "MCTestDeployment" --resource-group "myresourcegroup" --template-file ".\mediacomposer\mediacomposerazuredeploy.json" --parameters ".\mediacomposer\mediacomposerazuredeploynvidia.parameters.json"</i>

<i>Example: ps> az deployment group create --name "MCTestDeployment" --resource-group "myresourcegroup" --template-file ".\mediacomposer\mediacomposerazuredeploy.json" --parameters ".\mediacomposer\mediacomposerazuredeployamd.parameters.json"</i>

<b> 8) If you need to duplicate Media Composer environment, follow the instructions below: </b>

a) Create a snapshot of the main os disk. <br />

[create snapshot](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/snapshot-copy-managed-disk)

b) Run script to duplicate snapshot x time. <br />

[duplicate snapshot script](scripts/create_disk_from_snapshot.ps1)

PS> .\create_disk_from_snapshot.ps1

c) Run script to create media composer VM from snapshot: 

PS> az deployment group create --name "xxx" --resource-group "xxxx" --template-file ".\mediacomposer\mediacomposercloning.json" --parameters "xxxx"

<br />

<b> 9) Deploy One Nexis storage module. </b>

<br />

| Module | Supported Version | ARM Template link |
| ------ | ------------------ | ----------------- |
| Nexis  | Avid Nexis Cloud 20.7.0 | <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fssengreleng.blob.core.windows.net%2Fnexisgold%2F20.7.0%2FAzureProvisioning%2Fnexis.nearline%2Fazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" /></a> |

<br />