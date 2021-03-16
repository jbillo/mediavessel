# mediavessel
Experiments with a containerized media server

# Getting Started
On a fresh Ubuntu 20.04 installation, pipe curl to sudo bash, as is the tradition with these web tools:

```
sudo apt-get -y install curl
curl -sfL https://raw.githubusercontent.com/jbillo/mediavessel/main/yolo.sh | sudo bash
```

This will create an `/opt/mediavessel` directory with a git clone of the repository so we can run the next series of scripts. If you want to change this beforehand, export `LOCAL_REPO_DIR` to the desired path.

## systemd automount

More detail in an upcoming blog post, but  you can use the Python helper to create systemd unit files that will automount a remote share when the directory is first accessed. For example, my terribly insecure connection to a Drobo 5N2 looks like:

```
sudo python3 /opt/mediavessel/create-automount.py //192.168.1.50/Data /mnt/5n2 --options "rw,vers=3.02,guest,_netdev,file_mode=0777,dir_mode=0777"
```

which will produce `/etc/systemd/system/mnt-5n2.{automount,mount}` files, run `systemctl daemon-reload`, and start and enable the unit.
