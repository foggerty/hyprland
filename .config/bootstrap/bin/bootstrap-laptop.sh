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
       thermald"

    to_install="$graphics_drivers \
            $graphics_intel \
            $power"

    info "Installing packages."
    sudo pacman --needed -Syu $to_install > /dev/null
}

detectSensors() {
    # Setup lm_sensors
    sudo sensors-detect --auto > /dev/null
}

enableServices() {
    info "Enabling laptop services."
    services=(thermald)

    for service in "${services[@]}"; do
        sudo systemctl enable --now "$service" -q
    done
}

run "Install packages? " installPackages
run "Run detect sensors? " detectSensors
run "Enable services? " enableServices
