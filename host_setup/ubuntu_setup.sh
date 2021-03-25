#!/bin/bash
echo "================================================================================"
echo "Upgrading Ubuntu Image"
echo "================================================================================"
echo
sudo apt-get upgrade
echo
sudo apt install vim
echo "================================================================================"
echo "Installing Azure CLI"
echo "================================================================================"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo az extension add --name azure-devops
echo
echo "================================================================================"
echo "Installing Python 3.6 and Pip3"
echo "================================================================================"
sudo apt install -y python3.6
sudo apt install -y python3-pip
sudo apt install -y python3-setuptools
echo
echo "================================================================================"
echo "Installing Ansible"
echo "================================================================================"
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
echo
echo "================================================================================"
echo "Installing Terraform"
echo "================================================================================"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get install terraform=0.14.4
sudo apt-get install packer
echo
echo "================================================================================"
echo "Done Ubuntu Setup"
echo "================================================================================"
