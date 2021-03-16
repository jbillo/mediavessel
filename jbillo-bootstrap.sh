#!/usr/bin/env bash
# Jake's home environment. You may want to use this as an example for your own deployment.
# Ensure /root/cifscreds is populated with the necessary credentials files.

sudo python3 /opt/mediavessel/create-automount.py //192.168.1.50/Data /mnt/5n2 --options "rw,vers=3.02,guest,_netdev,file_mode=0777,dir_mode=0777"
sudo python3 /opt/mediavessel/create-automount.py //192.168.1.4/Data /mnt/drobo5n --options "rw,vers=3.02,guest,_netdev,file_mode=0777,dir_mode=0777"
sudo python3 /opt/mediavessel/create-automount.py //192.168.1.3/Seagate8TB /mnt/seagate8tb --options "rw,vers=3.02,forceuid,file_mode=0777,dir_mode=0777,credentials=/root/cifscreds/windows"
sudo python3 /opt/mediavessel/create-automount.py //192.168.1.9/Data /mnt/ds418 --options "rw,vers=3.02,file_mode=0777,dir_mode=0777,credentials=/root/cifscreds/nas"
