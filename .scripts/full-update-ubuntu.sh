#!/bin/bash
# Updates apt and flatpak packages
# Run without sudo

sudo -v

read -t 10 -p "Shutdown Afterwards (Y/N): " confirm

if [[ "$confirm" = [yY] ]] || [[ "$confirm" = [yY][eE][sS] ]]
then
	echo 'System will shutdown after updates'
fi

echo && echo
echo 'Updating apt packages'
sudo apt update && sudo apt full-upgrade -y --allow-downgrades
sudo apt update && sudo apt autoremove --purge -y

echo && echo
echo 'Updating flatpak system packages'
sudo flatpak upgrade -y
sudo flatpak uninstall -y --unused 

echo && echo
echo 'Updating flatpak user packages'
flatpak upgrade -y
flatpak uninstall -y --unused 

if [[ "$confirm" = [yY] ]] || [[ "$confirm" = [yY][eE][sS] ]]
then
	shutdown now
fi
