#!/usr/bin/env bash
# Bootstrap an Ubuntu 22.04 system (VM or bare-metal) with some common tools. 
# This has been tested on the server edition with HWE kernel.
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

echo "Disabling password prompt for sudo group"
# sudoers.d contents are processed after the /etc/sudoers file, so the NOPASSWD config takes precedence
echo "%sudo  ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nopasswd-sudo-group

echo "Cloning mediavessel repo to ${LOCAL_REPO_DIR:=/opt/mediavessel}"
mkdir -p "${LOCAL_REPO_DIR}"

# Ensure our package lists are updated and packages upgraded, and that we install security updates automatically
# https://unix.stackexchange.com/questions/107194/make-apt-get-update-and-upgrade-automate-and-unattended
DEBIAN_FRONTEND=noninteractive apt-get -y update 
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade 
DEBIAN_FRONTEND=noninteractive apt-get -y install unattended-upgrades

# Install useful system tools.
DEBIAN_FRONTEND=noninteractive apt-get -y install \
   curl \
   git \
   openssh-server \
   cifs-utils \
   vim \
   net-tools \
   apt-transport-https \
   ca-certificates \
   software-properties-common \
   gnupg

# Add Docker repo and key; update repo list
install -m 0755 -d /etc/apt/keyrings
rm -f /etc/apt/keyrings/docker.gpg || true
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
 
echo \
 "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
 "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
 tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

# Install Docker and components
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Disabled temporarily
# Fix xrdp so that it can read the snakeoil certificate. Not critical to the whole operation though so ignore failure.
# https://linuxize.com/post/how-to-install-xrdp-on-ubuntu-20-04/
# adduser xrdp ssl-cert || true
# systemctl restart xrdp || true

# Clone this repository locally (if needed) and update it
git clone "https://github.com/jbillo/mediavessel.git" "${LOCAL_REPO_DIR}" || true
pushd "${LOCAL_REPO_DIR}"; git fetch --all; git reset --hard origin/main; popd
