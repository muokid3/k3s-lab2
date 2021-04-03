#!/bin/bash


# Upgrade and install basics
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y curl vim jq git make docker.io unzip
sudo usermod -aG docker ubuntu

# Install oh-my-bash and remove snap
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BryanDollery/remove-snap/main/remove-snap.sh)"

# Install K3D
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

echo 'alias cp="ssh -oStrictHostKeyChecking=no cp.k3s.lab"' >> .bashrc
rm -f provision.sh
