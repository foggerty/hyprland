#!/usr/bin/env bash

source ~/.config/bootstrap/bin/lib.sh

CONSOLE_FONT="sun12x22"
EXCLUDE_FILES=(
    "NoExtract=/usr/lib/thunarx-3/thunar-wallpaper-plugin.so"
    "NoExtract=/etc/xdg/autostart/*"
)

installParu() {
    info "Installing Paru."

    if [[ ! -d "$HOME/dev" ]]; then
        mkdir ~/dev > /dev/null
    fi

    pushd "$HOME/dev" || exit 1

    if [[ ! -d "$HOME/dev/paru" ]]; then
        git clone https://aur.archlinux.org/paru.git
    fi

    cd paru || exit 1

    makepkg -si

    popd || exit 1
}

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
    info "Setting up Greetd/"
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
    # List of system services to enable/start.
    services=(avahi-daemon \
                  bluetooth \
                  greetd \
                  opensnitchd \
                  ufw)

    # List of user services to enable/start.
    user_services=(emacs foot-server mpd)

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
    if ! grep "FONT=$CONSOLE_FONT" /etc/vconsole.conf; then
        echo "FONT=$CONSOLE_FONT" | sudo tee -a /etc/vconsole.conf
    fi

    # Set standard XDG user directories
    info "Upading XDG user directories."
    xdg-user-dirs-update

    # I don't plan on deleting these dierectories, so a service to ensure they
    # still exist is wasted overhead.
    sudo systemctl --global disable xdg-user-dirs-update -q

    # Setup default mime-types - only uncomment if you're read the script and
    # understand it.
    # info "Setting mime-type defaults."
    # "$HOME"/.config/bootstrap/bin/set-mime-defaults.sh

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
         blueman \
         cachy-update \
         cliphist wl-clipboard \
         evince \
         foliate \
         galculator \
         pipewire pipewire-pulse wireplumber \
         power-profiles-daemon \
         journalctl-desktop-notification \
         mpd rmpc \
         pamixer \
         nwg-displays \
         rofi \
         ristretto\
         swaylock swayidle \
         swww \
         waybar \
         wlogout \
         vlc vlc-plugin-ffmpeg \
         xdg-desktop-portal-gtk \
         xdg-terminal-exec \
         xfce4-notifyd \
         zeal"
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
         tumbler tumbler-extra-thumbnailers"
    fonts="adobe-source-code-pro-fonts \
         cantarell-fonts \
         font-manager \
         noto-fonts-cjk noto-fonts-emoji \
         ttf-nerd-fonts-symbols-mono"
    greeter="greetd greetd-tuigreet"
    hyprland="hyprland \
              hyprlock \
              hypridle \
              hyprshot \
              hyprshutdown \
              hyprsysteminfo \
              hyprpwcenter \
              wlr-dpms \
              xdg-desktop-portal-hyprland"
    libraries="libgccjit lua-luv libotf"
    networking="iwd networkmanager network-manager-applet"
    niri="niri pavucontrol xdg-desktop-portal-gtk"
    security="lxsession
              opensnitch \
              python-qt-material \
              ufw"
    terminal="bash-completion foot starship tealdeer"
    theme="deepin-gtk-theme \
         obsidion-icon-thene \
         imagemagick \
         nwg-look \
         qt6ct \
         wallust"
    utilities="7zip zip unrar-free unzip \
         btop htop \
         bat \
         btrfs-assistant \
         figlet \
         fzf \
         lshw lsof \
         mc \
         ncdu \
         pacman-contrib \
         pciutils\
         ripgrep \
         util-linux \
         tree"

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

    desktop="$niri"

    # Install requirements for bootstrap
    info Installing git and base-devel.
    sudo pacman --needed -S git base-devel

    # Install packages
    info "Installing packages."
    sudo pacman --needed -Syu $to_install
    sudo pacman --needed -Syu $desktop

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
    sudo limine-mkinitcpio -P
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
