#!/bin/bash

#echo "Changing umask to 027..."
#sudo sed -i -r 's/^UMASK.*$/UMASK\t\t022/' /etc/login.defs

echo "Diabling various modules..."
sudo cp ~/.config/harden/modules-blacklist.conf /etc/modules-load.d/

echo "Turning off core-dump in Systemd."
if [[ ! -d /etc/systemd//coredump.conf.d ]]; then
    sudo mkdir -p /etc/systemd/coredump.conf.d
fi
sudo tee /etc/systemd/coredump.conf.d/custom.conf <<EOF
[Coredump]
Storage=none
ProcessSizeMax=0
EOF

echo "Turning off core-dump in PAM"
if [[ ! -d /etc/security/limits.d ]]; then
    sudo mkdir -p /etc/security/limits.d
fi
sudo tee /etc/security/limits.d/core-dump.conf <<EOF
* hard core 0
EOF
