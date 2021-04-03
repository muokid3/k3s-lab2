#!/bin/bash

echo "Provisioning K3S server..."

# Basics
sudo apt update
sudo apt upgrade
sudo apt install -y curl vim jq git make docker.io unzip
sudo usermod -aG docker ubuntu
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# Install k3s
curl -sfL https://get.k3s.io | \
        K3S_TOKEN=wibble \
        INSTALL_K3S_CHANNEL=latest \
        INSTALL_K3S_EXEC="server --disable=traefik" \
        bash -

. prep.sh
kubectl taint node $(hostname) k3s-controlplane=true:NoSchedule

# Install Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash


# Install nginx baremetal on ports 30000 and 30001
kubectl apply -f nginx-ingress-deploy.yaml

# Install Krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"${OS}_${ARCH}" &&
  "$KREW" install krew
)

echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> .bashrc

# Use krew to install kubectl plugins
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl krew update
kubectl krew install get-all change-ns ingress-nginx janitor doctor ns pod-dive pod-inspect pod-lens pod-logs pod-shell podevents service-tree sick-pods view-secret

bash -c "$(curl -fsSL https://raw.githubusercontent.com/BryanDollery/remove-snap/main/remove-snap.sh)"

# Finally, add an alias for kubectl
echo 'alias k=kubectl' >> .bashrc
echo 'alias less="less -R"' >> .bashrc
echo 'alias jq="jq -C"' >> .bashrc

# and tidy up
rm ~/provision.sh
rm ~/nginx-ingress-deploy.yaml
mkdir git

# Out
echo "Provisioning K3S server complete"