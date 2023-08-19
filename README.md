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

## systemd automount

Needs to be reworked; automount on the previous incarnation blasted syslog with "already mounted" messages from the mediavessel tooling. Generally automount hasn't worked in the event of power/network interruptions anyway so I might just fall back to `/etc/fstab`.