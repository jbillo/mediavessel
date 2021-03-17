#!/usr/bin/env bash
# Bootstrap an Ubuntu 20.04 system (VM or bare-metal) with some common tools. This has been tested on the Desktop ISO, but should work similarly for the server edition.
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

echo "Will clone mediavessel repo to ${LOCAL_REPO_DIR:=/opt/mediavessel}"
mkdir -p "${LOCAL_REPO_DIR}"

# Ensure our package lists are updated and packages upgraded, and that we install security updates automatically
# https://unix.stackexchange.com/questions/107194/make-apt-get-update-and-upgrade-automate-and-unattended
DEBIAN_FRONTEND=noninteractive apt-get -y update 
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade 
DEBIAN_FRONTEND=noninteractive apt-get -y install unattended-upgrades

# Install useful system tools
DEBIAN_FRONTEND=noninteractive apt-get -y install git openssh-server xrdp cifs-utils vim net-tools apt-transport-https ca-certificates software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install docker-ce

# Install docker-compose from linuxserver.io
curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Fix xrdp so that it can read the snakeoil certificate. Not critical to the whole operation though so ignore failure.
# https://linuxize.com/post/how-to-install-xrdp-on-ubuntu-20-04/
adduser xrdp ssl-cert || true
systemctl restart xrdp || true

# Clone this repository locally (if needed) and update it
git clone "https://github.com/jbillo/mediavessel.git" "${LOCAL_REPO_DIR}" || true
pushd "${LOCAL_REPO_DIR}"; git fetch --all; git reset --hard origin/main; popd
