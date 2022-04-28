#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root:"
	echo "    sudo ./finish_misterarch_install.sh"
	exit
fi

cd /
set -o xtrace

{ echo "Expand rootfs partition to fill the SD card..."; } 2> /dev/null
echo -e "Yes" | parted /dev/mmcblk0 resizepart 3 "100%" ---pretend-input-tty
btrfs filesystem resize max /

{ echo "Pacman keyring..."; } 2> /dev/null
pacman-key --init
pacman-key --populate archlinuxarm

{ echo "Update everything..."; } 2> /dev/null
pacman -Syu --noconfirm

{ echo "Clean up this script..."; } 2> /dev/null
rm -Rfv {~,~alarm}/finish_misterarch_install.sh /media/fat/*

{ echo -n "Want to populate /media/fat with Distribution_MiSTer? [Y/n] "; read -r shouldwe; } 2> /dev/null
if [[ $shouldwe =~ ^([yY][eE][sS]|[yY]?)$ ]]; then
	git clone https://github.com/MiSTer-devel/Distribution_MiSTer.git /media/fat --depth=1

	# These are all not applicable on MiSTerArch and might even be dangerous
	rm -Rf /media/fat/Scripts/
fi

{ echo "Done! Perhaps reboot nicely; the kernel and mister-main might have been updated."; } 2> /dev/null
