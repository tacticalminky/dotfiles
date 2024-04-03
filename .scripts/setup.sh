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
    ~/workspace/virtualbox-vms/ISOs
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
    net.davidotek.pupgui2               # ProtonUp-Qt (Proton version manager)
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
    us.zoom.Zoom                        # Zoom (scum of the earth)
    #md.obsidian.Obsidian                # Obsidian (markdown notes app)
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
        man-db                  # Man
        man-pages               # Man Pages
        posix-user-portability  # POSIX shell and utils
        xdg-user-dirs           # User directories
        wl-clipboard            # Wayland copy/paste
        ttf-firacode-nerd       # FiraCode Nerd Font
        ttf-liberation          # Liberation Font
        perl-rename             # Bulk renaming tool
        pipewire                # Audio processor
        bluez                   # Bluetooth daemon
        flatpak                 # Flatpak
        gtk3                    # GTK3 for kitty
        gamescope               # GameScope compositor
        qt5-wayland             # Qt5 Wayland support
        qt6-wayland             # Qt5 Wayland support
        polkit-kde-agent        # Pop-up auth agent
    )

    desktop_pkgs=(
        hyprland    # Window manager
        hyprpaper   # Wallpaper utility
        waybar      # Task bar
        fuzzel      # Application launcher
        swayidle    # Idle management daemon
        swaylock    # Screen locker
        dunst       # Notification Deamon
        greetd-regreet  # Login manager
        xdg-desktop-portal-hyprland # xdg-desktop backend for Hyprland
    )

    application_pkgs=(
        kitty       # Terminal
        neovim      # Text editor
        nautilus    # File manager
        blueman     # Bluetooth manager
        piper       # Logitech Mouse Button and RGB Mapper
        steam       # Steam
        mangohud    # Game Monitoring HUD
        virtualbox  # VitualBox
        gnome-calculator # Calculator
    )

    dev_pkgs=(
        npm             # Node and NPM
        jdk17-openjdk   # Java 17 JDK
        maven           # Java build tools
        docker          # Docker
        docker-compose  # Docker Compose
    )

    optional_dep_pkgs=(
        pipewire-jack       # JACK replacement w/ pipewire
        python-pynvim       # Python runtime for Neovim
        otf-font-awesome    # Font Awesome Icons
        nvidia-settings     # NVIDIA GPU configuring
    )

    echo && echo
    echo 'Installing utility packages'
    sudo pacman -S ${util_pkgs[*]}

    echo && echo
    echo 'Installing optional dependency packages'
    sudo pacman -S --asdeps ${optional_dep_pkgs[*]}

    echo && echo
    echo 'Installing desktop and application packages'
    sudo pacman -S ${desktop_pkgs[*]} ${application_pkgs[*]} ${dev_pkgs[*]}

    echo && echo
    echo 'Updating pacman packages'
    sudo pacman -Syuu

    echo && echo
    echo 'Removing orphaned packages'
    sudo pacman -Qtdq | sudo pacman -Rns -

    echo && echo
    echo 'Cleaning pacman cached packages'
    sudo pacman -Sc

    # echo && echo
    # echo 'Creating user directories'
    # xdg-user-dirs-update
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

    apt_packages=(
        vim             # CLI text editor
        kitty           # Terminal
        make            # Build tool
        stacer          # System Optimizer and Monitoring
        python3-pip     # Python Package Manager
        ckb-next        # Corsair Keyboard RGB Driver
        openjdk-17-jdk  # Java 17 JDK
        maven           # Java build tool
        piper           # Logitech Mouse Button and RGB Mapper
        steam           # Steam
        mangohud        # Game Monitoring HUD
        code            # Visual Studio Code
        virtualbox      # VirtualBox VM Manager
        ifuse           # Apple iOS files
    )

    echo && echo
    echo 'Installing APT packages'
    sudo apt install -y ${apt_packages[*]}

    echo && echo
    echo 'Updating and cleaning APT packages'
    sudo apt update && sudo apt full-upgrade -y --allow-downgrades
    sudo apt update && sudo apt autoremove -y && sudo apt clean

    echo && echo
    echo 'Installing Neovim from source'
    git clone https://github.com/neovim/neovim .neovim
    cd .neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
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

