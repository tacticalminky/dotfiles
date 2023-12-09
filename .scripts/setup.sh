#!/bin/bash
# Run without sudo

sudo -v

read -p """
Please Select a Distrobution:
    1. Arch
    2. PopOS!
Select: """ distro
echo

if [[ "$dist" != 1 ]] && [[ "$dist" != 2 ]]
then
	echo 'Selection not available, please try again!'
	exit 1
fi

read -p "Restart Afterwards (Y/N): " confirm_restart

# echo 'Moving files into place'
# cp -r home/* ~/

#---------------------------------------------
# Create new directories
#---------------------------------------------
echo && echo 'Creating directories: ~/workspace ~/games'
workspace_directories=(
    ~/workspace
    ~/workspace/blender
    ~/workspace/gimp
    ~/workspace/virtualbox-vms
)
game_directories=(
    ~/games
    ~/games/steam
    ~/games/heroic
    ~/games/heroic/.prefixes
    ~/games/ps3
)
mkdir ${workspace_directories[*]} ${game_directories[*]}

#---------------------------------------------
# Create lists of common packages
#---------------------------------------------
common_pkgs=()

common_flatpak_pkgs=(
    # Utilities
    com.github.tchx84.Flatseal          # Flatseal (flatpak permissions)
    com.usebottles.bottles              # Bottles (run windows software)

    # Dev Work
    com.getpostman.Postman              # Postman (API calls)
    org.cockpit_project.CockpitClient   # Cockpit Remote Client

    # Gaming
    com.discordapp.Discord              # Discord
    net.davidotek.pupgui2               # ProtonUp-Qt
    com.heroicgameslauncher.hgl         # Heroic Games Launcher (Epic launcher)
    net.rpcs3.RPCS3                     # RPCS3 (PS3 emulator)
    com.mojang.Minecraft                # Minecraft
    org.prismlauncher.PrismLauncher     # Prism (Minecraft modpack launcher)
    com.github._0negal.Viper            # Viper (Titanfall 2 Launcher)

    # Creativity
    org.blender.Blender                 # Blender (3D modeler)
    org.gimp.GIMP                       # GIMP (image processor)
    fr.handbrake.ghb                    # Handbrake (video encoder)

    # Office
    org.mozilla.Thunderbird             # Thunderbird (email client)
    us.zoom.Zoom                        # Zoom
    md.obsidian.Obsidian                # Obsidian (Markdown notes app)
    com.github.johnfactotum.Foliate     # Foliate (ePub reader)
)

#---------------------------------------------
# Arch specific packages and commands
#---------------------------------------------
setup_arch() {
    echo && echo 'Creating directory for AURs: ~/.aur'
    mkdir ~/.aur

    additional_flatpak_pkgs=(
        org.mozilla.firefox         # Firefox
        org.libreoffice.LibreOffice # LibreOffice Suite
    )

    util_pkgs=(
        xdg-user-dirs           # User directories
        bluez                   # Bluetooth daemon
        pipewire                # Audio processor
        flatpak                 # Flatpak
        perl-rename             # Bulk renaming tool
        ttf-firacode-nerd       # FiraCode Nerd Font
        posix-user-portability  # POSIX shell and utils
    )

    desktop_pkgs=(
        hyprland    # Window manager
        hyprpaper   # Wallpaper utility
        waybar      # Task bar
        fuzzel      # Application launcher
        swaylock    # Screen locker
        dunst       # Notification Deamon
    )

    application_pkgs=(
        kitty       # Terminal
        neovim      # Text editor
        nautilus    # File manager
        steam       # Steam
        piper       # Logitech Mouse Button and RGB Mapper
        mangohud    # Game Monitoring HUD
        virtualbox  # VitualBox
    )

    echo && echo
    echo 'Installing pacman packages'
    sudo pacman -Sy ${util_pkgs[*]} ${desktop_pkgs[*]} ${application_pkgs[*]}

    echo && echo
    echo 'Updating and cleaning pacman packages'
    sudo pacman -Sycuu

    xdg-user-dirs-update
}

#---------------------------------------------
# PopOS! specific packages and commands
#---------------------------------------------
setup_pop() {
    additional_flatpak_pkgs=()

    echo && echo
    echo 'Removing unwanted packages'
    sudo apt autoremove --purge -y geary

    echo 'Enabling Nvidia writing to xorg.conf'
    sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit

    echo && echo
    echo 'Installing APT packages'
    apt_packages=(
        vim             # CLI text editor
        make            # build tool
        stacer          # System Optimizer and Monitoring
        python3-pip     # Python Package Manager
        ckb-next        # Corsair Keyboard RGB Driver
        piper           # Logitech Mouse Button and RGB Mapper
        steam           # Steam
        mangohud        # Game Monitoring HUD
        code            # Visual Studio Code
        virtualbox      # VirtualBox VM Manager
    )
    sudo apt install -y ${apt_packages[*]}

    echo && echo
    echo 'Updating and cleaning APT packages'
    sudo apt update && sudo apt full-upgrade -y --allow-downgrades
    sudo apt update && sudo apt autoremove -y && sudo apt clean

    echo && echo
    echo 'Installing Neovim from source'
    git clone https://github.com/neovim/neovim
    cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
    git checkout stable
    cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
}

#---------------------------------------------
# Flatpak installation commands
#---------------------------------------------
flatpak_installs() {
    echo && echo
    echo 'Installing Flatpak packages'
    flatpak --user install -y ${common_flatpak_pkgs[*]} ${additional_flatpak_pkgs[*]}

    echo && echo
    echo 'Updating Flatpak packages'
    flatpak upgrade -y
    flatpak uninstall -y --unused
}

case $distro in
    1)
        setup_arch
        flatpak_installs
        ;;

    2)
        setup_pop
        flatpak_installs
        ;;
esac

if [[ "$confirm_restart" = [yY] ]] || [[ "$confirm_restart" = [yY][eE][sS] ]]
then
    shutdown -r now
fi

