#!/bin/bash

# Run without sudo

sudo -v

read -p "Restart Afterwards (Y/N): " confirm_restart

#-------------------------------------------------------
# List new directories
#-------------------------------------------------------
workspace_directories=(
    ~/workspace
    ~/workspace/blender
    ~/workspace/gimp
    ~/workspace/handbrake
    ~/workspace/handbrake/encoded
    ~/workspace/handbrake/raw
    ~/workspace/handbrake/profiles
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

echo && echo 'Creating directories: ~/workspace ~/games'
mkdir ${workspace_directories[*]} ${game_directories[*]}

#-------------------------------------------------------
# List packages
#-------------------------------------------------------
pkgs_to_remove=(
    geary
)

apt_pkgs=(
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
    #ifuse           # Apple iOS files
    #caffeine        # Temporarily deacivate sceensaver and sleep
)

flatpak_pkgs=(
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
    #us.zoom.Zoom                        # Zoom (scum of the earth)
    #md.obsidian.Obsidian                # Obsidian (markdown notes app)
    #com.github.johnfactotum.Foliate     # Foliate (ePub reader)
)

#-------------------------------------------------------
# Uninstall unwanted packages and install wanted ones
#-------------------------------------------------------

echo && echo
echo 'Updating and cleaning APT packages'
sudo apt update && sudo apt full-upgrade -y --allow-downgrades
sudo apt update && sudo apt autoremove -y && sudo apt clean

echo && echo
echo 'Removing unwanted packages'
sudo apt autoremove --purge -y ${pkgs_to_remove[*]}

echo && echo
echo 'Installing APT packages'
sudo apt install -y ${apt_pkgs[*]}

echo && echo
echo 'Installing Flatpak packages'
flatpak --user install -y ${common_flatpak_pkgs[*]} ${additional_flatpak_pkgs[*]}

echo && echo
echo 'Updating Flatpak packages'
flatpak upgrade -y
flatpak uninstall -y --unused

# echo && echo
# echo 'Installing Neovim from source'
# git clone https://github.com/neovim/neovim .neovim
# cd .neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
# git checkout stable
# cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb

# echo 'Enabling Nvidia writing to xorg.conf'
# sudo chmod u+x /usr/share/screen-resolution-extra/nvidia-polkit

if [[ "$confirm_restart" = [yY] ]] || [[ "$confirm_restart" = [yY][eE][sS] ]]
then
    shutdown -r now
fi

