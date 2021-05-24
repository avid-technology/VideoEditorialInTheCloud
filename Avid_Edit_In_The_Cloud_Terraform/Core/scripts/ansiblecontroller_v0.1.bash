#!/bin/bash
echo "================================================================================"
echo "Upgrading Ubuntu Image"
echo "================================================================================"
echo
sudo apt-get update
sudo apt-get upgrade
echo
echo "================================================================================"
echo "Install vim package"
echo "================================================================================"
echo
sudo apt install vim
echo
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
sudo apt-add-repository --yes --update ppa:ansible/ansible-2.9 # point to specific 2.9 version
sudo apt install -y ansible
sudo apt install -y python-pip
sudo pip install "pywinrm>=0.3.0"
sudo curl "https://eitcstore01.blob.core.windows.net/scripts/ansible.cfg$2" >> /home/$1/ansible.cfg # overwrite ansible config. Disable host key check. Not recommended in production.
sudo cp /home/$1/ansible.cfg /etc/ansible/ansible.cfg
sudo curl "https://eitcstore01.blob.core.windows.net/scripts/inventory.yml$2" >> /home/$1/inventory.yml # example of inventory file for ansible.
sudo chown $1:$1 /home/$1/ansible.cfg
sudo chown $1:$1 /home/$1/inventory.yml
sudo ansible-galaxy collection install chocolatey.chocolatey  -p /usr/share/ansible/collections
sudo ansible-galaxy collection install ansible.windows  -p /usr/share/ansible/collections
sudo ansible-galaxy collection install community.windows  -p /usr/share/ansible/collections
sudo pip install "requests-credssp" # For domain credentials login, install credssp
# sudo chown -R $1:$1 /home/$1/.ansible
echo
echo "================================================================================"
echo "Installing Terraform"
echo "================================================================================"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get install terraform=0.15.4
sudo apt-get install packer
echo
echo
echo "================================================================================"
echo "Generate SSH key pair for Ansible"
echo "================================================================================"
echo
ssh-keygen -f /home/$1/.ssh/id_rsa -t rsa -N ''
sudo chown $1:$1 /home/$1/.ssh/id_rsa.pub
sudo chown $1:$1 /home/$1/.ssh/id_rsa
echo
echo "================================================================================"
echo "Install Az copy"
echo "================================================================================"
echo
sudo wget https://aka.ms/downloadazcopy-v10-linux
sudo tar -xvf downloadazcopy-v10-linux
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
echo
echo "================================================================================"
echo "Download Ansible Roles in Controller Node"
echo "================================================================================"
echo
sudo azcopy copy "https://eitcstore01.blob.core.windows.net/scripts/Ansible$2" "/home/$1/" --recursive
sudo chown -R $1:$1 /home/$1/Ansible
echo
echo "================================================================================"
echo "Done Ubuntu Setup"
echo "================================================================================"
