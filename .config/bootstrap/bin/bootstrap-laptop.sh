################################################################################
#
# This is for bootstrapping MY laptop (Dell XPS 13 9380) for MY use.
# Use at your peril.
#
#

#!/usr/bin/env bash

source "$HOME/.config/bootstrap/bin/lib.sh"

installPackages() {
    graphics_drivers="ffmpeg \
                  libva-intel-driver \
                  libvdpau-va-gl \
                  mesa"

    graphics_intel="vulkan-intel intel-media-driver"

    power="brightnessctl \
       lm_sensors \
       thermald \
       tlp \
       wlr-dpms"

    security="ufw"

    to_install="$graphics_drivers \
            $graphics_intel \
            $power \
            $security"

    info "Installing packages."
    paru --needed --skipreview -Syu $to_install > /dev/null
}

setupTLP() {
    # Copy TLP configuration.
    info "Setting TLP configuration."
    sudo cp ~/.config/bootstrap/tlp/10-grayarea.conf /etc/tlp.d/
}

detectSensors() {
    # Setup lm_sensors
    sudo sensors-detect --auto > /dev/null
}

enableServices() {
    info "Enabling laptop services."
    services=(thermald tlp ufw)

    for service in "${services[@]}"; do
        sudo systemctl enable --now "$service" -q
    done
}

enableUfw() {
    sudo ufw default deny
    sudo ufw allow from 192.168.0.0/24
    sudo ufw allow Deluge

    sudo ufw enable
}

run "Install packages? " installPackages
run "Enable UFW? " enableUfw
run "Setup TLP? " setupTLP
run "Run detect sensors? " detectSensors
run "Enable services? " enableServices
