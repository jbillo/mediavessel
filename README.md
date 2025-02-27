# mediavessel
Experiments with a containerized media server - February 2025 update

# Installation
Assign a static DHCP lease to the system in question for convenience.
Install Ubuntu Server 24.04.2 LTS. There was no HWE kernel option during setup (I had a 24.04.1 image) but this can be installed and enabled later.
* Use GPT/btrfs for root volume; make sure LVM is extended to fill the disk (default seemed to be 100GiB, on my 2TiB NVMe drive I had to enter `1.860TB`)
* Enable SSH for easy system access, but make sure the host is not directly exposed to the Internet; select a strong passphrase for the initial user and make sure to store it in your password manager

# Basic Configuration
I don't intend to maintain the previous `yolo.sh` so replicating a bunch of the original script here with inline comments as to why.

```
# SSH to the system
ssh user@192.168.1.6

# Authorize your SSH public key for the first user.
# ssh-copy-id not available by default on macOS so do this the old fashioned way, eg: on localhost:
# pbcopy < ~/.ssh/id_rsa.pub

# Get in as root the first time 
sudo -i

# Disable password prompt for sudo operations
# sudoers.d contents are processed after the /etc/sudoers file, so the NOPASSWD config takes precedence
echo "%sudo  ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nopasswd-sudo-group

# Ensure our package lists are updated and packages upgraded, and that we install security updates automatically
# https://unix.stackexchange.com/questions/107194/make-apt-get-update-and-upgrade-automate-and-unattended
DEBIAN_FRONTEND=noninteractive apt-get -y update 
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade 
DEBIAN_FRONTEND=noninteractive apt-get -y install unattended-upgrades

# Install HWE kernel, then reboot
DEBIAN_FRONTEND=noninteractive apt-get -y install linux-generic-hwe-24.04

# Install Docker, using instructions from https://docs.docker.com/engine/install/ubuntu/
# podman might be an interesting option next time...

# We'll need cifs-utils to properly be able to mount SMB3.1 volumes
DEBIAN_FRONTEND=noninteractive apt-get -y install cifs-utils
```

# Configuring NAS mounts
We assume that multiple NAS-type devices need to be mounted. With a previous experiment, automount was somewhat painful so we're going to fall back to fstab.

For Windows/CIFS/SMB filesystems, newer kernels support the "smb3" filesystem type (`man mount.cifs`) and will auto-negotiate the highest SMB version supported by both client and server.

Therefore, a reasonable line to add to `/etc/fstab` could look like:

```
//192.168.1.30/Data /mnt/ds1821plus smb3 credentials=/root/.nascreds,rw,uid=1000,file_mode=0777,dir_mode=0777,nofail,x-systemd.automount,_netdev 0 0
```

Make sure the /root/.nascreds file is only readable by root. The format is

```
username=value
password=value
domain=value
```

with the `domain` line as optional. 

Run `systemctl daemon-reload; mount -a` to mount all fstab devices. 

After mounting, `cat /proc/mounts` to show version information and other options that were applied.

# Docker, docker-compose and containers

In the `docker/` directory of this repo, there are several directories that contain `docker-compose.yml` files. There is also a `up.sh` file that can be invoked to download the latest container image and restart the container, eg:

```
cd /opt/mediavessel/docker/nzbget
../up.sh
```

See: https://www.reddit.com/r/linuxquestions/comments/o8ubpc/docker_starts_before_filesystem_mounts/

# Other things

## Monitor Intel GPU usage

```
DEBIAN_FRONTEND=noninteractive apt-get -y install intel-gpu-tools
# once installed, run:
intel_gpu_top
```

# Credits/additional references
* https://medium.com/@luukb/setting-up-plex-media-server-on-ubuntu-docker-on-beelink-s12-n100-60688bd56cc2
