#!/usr/bin/env bash
# Install K3s and Helm, then add the k8s-at-home Helm chart repo.
# Credit to https://kvz.io/bash-best-practices.html for bash preamble

set -o errexit
set -o pipefail
set -o nounset

# Check if we're root
# https://askubuntu.com/questions/15853/how-can-a-script-check-if-its-being-run-as-root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

curl -sfL https://get.k3s.io | sh -

mkdir -p /root/.kube
ln -snf /etc/rancher/k3s/k3s.yaml /root/.kube/config

# Get Helm installed
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Add k8s-at-home Helm repo
helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo update

# Create mediavessel namespace
kubectl apply -f namespace.yaml
