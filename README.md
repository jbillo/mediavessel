# mediavessel
Experiments with a containerized media server

# Getting Started
Install Ubuntu 22.04 LTS, with HWE kernel option. Notable installation config includes:
* Use GPT/btrfs for root volume 
* Enable SSH for easy system access, but make sure the host is not directly exposed to the Internet

Then pipe `wget` (installed by default, curl comes later) to `sudo bash`, as is the tradition when installing software from the Internet:

```
wget -q -O - https://raw.githubusercontent.com/jbillo/mediavessel/main/yolo.sh | sudo bash
```

This will create an `/opt/mediavessel` directory with a git clone of the repository so we can run the next series of scripts. If you want to change this beforehand, export `LOCAL_REPO_DIR` to the desired path.

# Configuring mounts
We assume that multiple NAS-type devices need to be mounted. With a previous experiment, automount was somewhat painful so we're going to fall back to fstab.

## Locally attached storage
Get the list of UUIDs with a combination of `fdisk -l` and `blkid`. For each disk, create a mountpoint under `/mnt` (eg: `mkdir -p /mnt/searaid1` and then add a line to `/etc/fstab` like:

```
/dev/disk/by-uuid/68959000-2fa1-4e54-aef4-c1c94b1dc06f /mnt/searaid1 btrfs defaults 0 2
```

For specific partitions, use `by-partuuid` in the `/dev/disk` path:

```
/dev/disk/by-partuuid/b5402f34-d21e-4ced-8183-3871e5ca9bb9 /mnt/crucialmx1 ext4 defaults 0 2
```

From `man fstab`, the last digit ("pass") for local disks can be set to 0 to avoid fsck operations. To check local disks: 

> The root filesystem should be specified with a fs_passno of 1, and other filesystems should have a fs_passno of 2.

Attempt to mount the disks live with `mount -a` and then confirm that you can list their contents.

If like me, you'd initially configured multiple disks with btrfs in a raid1-style configuration, confirm that both are shown with `btrfs fi show`, then look for `Total devices`.

See the [fstab](fstab) file for my configuration, I'm not really concerned if you know my naming conventions or disk UUIDs.

Once the disk has been mounted, confirm (eg: with `ls`) that the user/group that your containers are running as will have access to the appropriate paths, including write if that's your choice.

## Network attached storage

For Windows/CIFS/SMB filesystems, newer kernels support the "smb3" filesystem type (`man mount.cifs`) and will auto-negotiate the highest SMB version supported by both client and server.

Therefore, a reasonable configuration to add to `/etc/fstab` could look like:

```
//192.168.1.50/Data /mnt/5n2 smb3 guest,rw,uid=1000,file_mode=0777,dir_mode=0777 0 0
```

If credentials are required, create a root-only readable file and use the `credentials=/path/to/creds` option. The file format is:

```
username=value
password=value
domain=value
```

After mounting, `cat /proc/mounts` to show version information and other options that were applied.

# Docker, docker-compose and containers

In the `docker/` directory of this repo, there are several directories that contain `docker-compose.yml` files. There is also a `up.sh` file that can be invoked to download the latest container image and restart the container, eg:

```
cd /opt/mediavessel/docker/nzbget
../up.sh
```

See: https://www.reddit.com/r/linuxquestions/comments/o8ubpc/docker_starts_before_filesystem_mounts/

## systemd automount

Needs to be reworked; automount on the previous incarnation blasted syslog with "already mounted" messages from the mediavessel tooling. Generally automount hasn't worked in the event of power/network interruptions anyway so I might just fall back to `/etc/fstab`.