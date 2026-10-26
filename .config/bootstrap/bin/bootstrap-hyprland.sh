#!/usr/bin/env bash

source ~/.config/bootstrap/bin/lib.sh

CONSOLE_FONT="sun12x22"
EXCLUDE_FILES=(
    "NoExtract=/usr/lib/thunarx-3/thunar-wallpaper-plugin.so"
    "NoExtract=/etc/xdg/autostart/*"
)

setupTheme() {
    # Remove Thunar's existing SetWallPaper menu item
    plugin="/usr/lib/thunarx-3/thunar-wallpaper-plugin.so"

    if [[ -f $plugin ]]; then
        info "Removing Thunar wallpaper plugin."
        sudo rm $plugin
    fi

    # Populate color configs
    info "Setting wallpaper and theme."
    ~/bin/paper both ~/Pictures/Wallpapers/current > /dev/null

    # Set GTK themes / keybindings.
    info "Setting up GTK."
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3
    gsettings set org.gnome.desktop.interface icon-theme Obsidian
    gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"
    gsettings set org.gnome.desktop.interface font-name "sans 13"
    gsettings set org.gnome.desktop.interface document-font-name "sans 13"
    gsettings set org.gnome.desktop.interface monospace-font-name "monospace 13"
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
}

setupDisplayManager() {
    info "Setting up Greetd."
    sudo mkdir -p /etc/geetd
    sudo cp ~/.config/bootstrap/etc/greetd/config.toml /etc/greetd/
}

setupIwd() {
    info "Configuring network-manager (using iwd as wireless backend)".
    sudo mkdir -p /etc/iwd
    sudo cp ~/.config/bootstrap/etc/iwd/iwd_main.conf /etc/iwd/main.conf
    sudo mkdir -p /etc/NetworkManager/conf.d/
    sudo cp ~/.config/bootstrap/etc/NetworkManager/conf.d/wifi_backend.conf /etc/NetworkManager/conf.d/wifi_backend.conf

    sudo systemctl enable NetworkManager
    sudo systemctl disable wpa_supplicant
    sudo systemctl enable iwd
}

setupServices() {
    # ToDo - move into a global so that setupIwd can append to it.
    # List of system services to enable/start.
    services=(avahi-daemon \
                  greetd \
                  opensnitchd \
                  ufw)

    # List of user services to enable/start.
    user_services=(emacs foot-server)

    info "Enabling system services."
    for service in "${services[@]}"; do
        sudo systemctl enable "$service"
    done

    info "Enabling user services."
    for service in "${user_services[@]}"; do
        systemctl --user enable "$service"
    done
}

setupEnvironment() {
    # Readable font in the TTY
    # Hey look, the grep expression doesn't consider that someone
    # may have commented out font deliberitly.
    # ToDo - remind user that they commented it out, so I'm assuming
    # they did so for a reason.
    if ! grep "FONT=$CONSOLE_FONT" /etc/vconsole.conf; then
        echo "FONT=$CONSOLE_FONT" | sudo tee -a /etc/vconsole.conf
    fi

    # Set standard XDG user directories
    info "Upading XDG user directories."
    xdg-user-dirs-update

    # Setup default mime-types
    info "Setting mime-type defaults."
    "$HOME"/.config/bootstrap/bin/set-mime-defaults.sh

    # Setup locale
    info "Setting XDG locale."
    echo "$LANG" | cut -f1 -d. > ~/.config/user-dirs.locale

    # Download tldr content
    info "Updating tldr database."
    tldr --update

    # Give gnome-keyring-daemon permission to tell the kernel not to store its
    # memory into swap, as it contains secrests and 'things'.
    #info "Setting capabilities for gnome-keyring-daemon."
    #sudo setcap cap_ipc_lock=+ep /usr/bin/gnome-keyring-daemon

    # Stop pacman from creating autostart files etc.
    for ex in "${EXCLUDE_FILES[@]}"
    do
        if ! grep "$ex" /etc/pacman.conf > /dev/null; then
            info "Excluding files from pacmnan updates:"
            echo "    $ex"
            sudo sed -i "/\[options\]/a $ex" /etc/pacman.conf
        fi
    done
}

installPackages() {
    basics="man linux-firmware openssh"
    browser="firefox"
    desktop="avahi \
         cliphist wl-clipboard \
         deluge \
         evince \
         foliate \
         galculator \
         opensnitch \
         pipewire pipewire-pulse wireplumber \
         power-profiles-daemon \
         pamixer \
         qt5-wayland \
         nwg-displays nwg-look \
         qpwgraph \
         ristretto \
         swaylock swayidle \
         swww \
         udiskie \
         waybar \

         xfce4-notifyd \
         xdg-desktop-portal-gtk \
	 xdg-user-dirs \
	 xdg-utils"
    development="cmake make"
    # I build Emacs manualy, so not included here.  Vi?  Vim?  Never heard of
    # em.
    editor="aspell aspell-en tree-sitter"
    file_manager="file-roller \
         ffmpegthumbnailer \
         gvfs gvfs-smb \
         nfs-utils \
         thunar thunar-archive-plugin thunar-volman \
         thunar-media-tags-plugin \
         tumbler"
    fonts="adobe-source-code-pro-fonts \
         cantarell-fonts \
         font-manager \
         noto-fonts-cjk noto-fonts-emoji \
         ttf-nerd-fonts-symbols-mono"
    greeter="greetd greetd-tuigreet"
    hyprland="hyprland \
              hyprshutdown \
              hyprpwcenter \
              xdg-desktop-portal-hyprland"
    libraries="libgccjit lua-luv libotf tree-sitter"
    networking="networkmanager network-manager-applet"
    niri="niri pavucontrol xdg-desktop-portal-gtk"
    security="lxsession \
              ufw"
    terminal="bash-completion foot starship tealdeer"
    theme="adw-gtk-theme \
         obsidian-icon-theme \
         imagemagick \
         matugen \
         nwg-look \
         qt5ct \
         qt6ct"
    utilities="7zip zip unrar-free unzip \
         bat \
         btrfs-assistant \
         figlet \
         fzf \
         htop \
         imagemagick \
         less \
         lshw lsof \
         mc \
         ncdu \
         pacman-contrib \
         pciutils\
         resources \
         ripgrep \
         util-linux \
         tealdeer \
         tree \
         which"

    to_install="$basics    \
         $browser          \
         $desktop          \
         $development      \
         $editor           \
         $file_manager     \
         $fonts            \
         $greeter          \
         $libraries        \
         $networking       \
         $security         \
         $terminal         \
         $theme            \
         $utilities"

    window_manager="$niri"

    # Install requirements for bootstrap
    info Installing git and base-devel.
    sudo pacman --needed -S git git-lfs base-devel

    # Install packages
    info "Installing packages."
    sudo pacman --needed -Syu $to_install
    sudo pacman --needed -Syu $window_manager

    if [[ "$?" -ne 0 ]]; then
        exit
    fi
}

setupUfw() {
    sudo ufw default deny
    sudo ufw allow from 192.168.0.0/24
    sudo ufw allow Deluge

    sudo ufw enable
}

rebuildKernel() {
    info Rebuiding kernel init images
    sudo mkinitcpio -P
}

# Install pacman if missing.
which pacman > /dev/null || installParu

run "Install packages? "      installPackages
run "Setup theme? "           setupTheme
run "Setup displaymanager? "  setupDisplayManager
run "Replace WPA with IWD? "  setupIwd
run "Setup environment? "     setupEnvironment
run "Setup services? "        setupServices
run "Setup UFW? "             setupUfw
run "Rebuild kernel images ?" rebuildKernel

echo "Reboot recomnended to start all services."
