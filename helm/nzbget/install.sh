#!/usr/bin/env bash
# Credit to https://kvz.io/bash-best-practices.html for bash preamble

set -o errexit
set -o pipefail
set -o nounset

# Make sure your kubectl is set per https://rancher.com/docs/k3s/latest/en/cluster-access/
helm install nzbget k8s-at-home/nzbget -f values.yaml --namespace mediavessel || helm upgrade nzbget k8s-at-home/nzbget -f values.yaml --namespace mediavessel
