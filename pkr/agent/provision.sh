#!/bin/bash
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y curl vim jq git make docker.io unzip
sudo usermod -aG docker ubuntu
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

curl -sfL https://get.k3s.io | \
        K3S_TOKEN=wibble \
        K3S_URL=https://cp.k3s.lab:6443 \
        INSTALL_K3S_CHANNEL=latest \
        INSTALL_K3S_SKIP_START=true \
        bash -

bash -c "$(curl -fsSL https://raw.githubusercontent.com/BryanDollery/remove-snap/main/remove-snap.sh)"

