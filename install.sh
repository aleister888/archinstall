#!/bin/bash

set -e

export REPO_NAME="archinstall"
export REPO_URL="https://github.com/aleister888/$REPO_NAME"
REPO_DIR="/tmp/archinstall"

if [ ! -d /sys/firmware/efi ]; then
	echo "El instalador solo soporta sistemas UEFI" >&2
	exit 1
fi

grep ubuntu /etc/pacman.d/gnupg/gpg.conf ||
	echo 'keyserver hkp://keyserver.ubuntu.com' |
	sudo /usr/bin/tee -a /etc/pacman.d/gnupg/gpg.conf >/dev/null

sudo /usr/bin/pacman -Sy
sudo /usr/bin/pacman -Sc --noconfirm
sudo /usr/bin/pacman -S --noconfirm --needed parted libnewt xkeyboard-config bc git lvm2

if [ -d ./installer ]; then
	cd ./installer || exit 1
else
	git clone --depth 1 "$REPO_URL.git" $REPO_DIR
	cd $REPO_DIR/installer || exit 1
fi

sudo ./stage1.sh
