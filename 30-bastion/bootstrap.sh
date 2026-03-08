#!/bin/bash
sudo growpart /dev/nvme0n1 4
sudo lvextend -r -L+30G /dev/mapper/RootVG-homeVol
sudo xfs_growfs /home

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform


