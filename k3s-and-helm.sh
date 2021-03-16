#!/usr/bin/env bash

# Credit to https://kvz.io/bash-best-practices.html for bash preamble

set -o errexit
set -o pipefail
set -o nounset

curl -sfL https://get.k3s.io | sh -

# Get Helm installed

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash