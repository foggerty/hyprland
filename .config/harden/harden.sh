#!/bin/bash

#echo "Changing umask to 027..."
#sudo sed -i -r 's/^UMASK.*$/UMASK\t\t022/' /etc/login.defs

echo "Diabling various kernel modules..."
sudo cp ~/.config/harden/modules-blacklist.conf /etc/modprobe.d/

echo "Turning off core-dump in Systemd."
if [[ ! -f /etc/systemd/coredump.conf.d/disable.conf ]]; then

    if [[ ! -d /etc/systemd/coredump.conf.d ]]; then
        sudo mkdir -p /etc/systemd/coredump.conf.d
    fi

    sudo tee /etc/systemd/coredump.conf.d/disable.conf <<EOF
    [Coredump]
    Storage=none
    ProcessSizeMax=0
EOF
fi

echo "Turning off core-dump in PAM"
if [[ ! -f /etc/secutiry/limits.d/core-dump.conf ]]; then

    if [[ ! -d /etc/security/limits.d ]]; then
        sudo mkdir -p /etc/security/limits.d
    fi

    sudo tee /etc/security/limits.d/core-dump.conf <<EOF
    * soft core 0          # default to 0
    * hard core unlimited  # allown users to enable
EOF
fi
