#!/bin/bash

set -e

export REPO_NAME="archinstall"
export REPO_URL="https://github.com/aleister888/$REPO_NAME"

REPO_CLONE_DIR="/tmp/archinstall"

#-------------------------------------------------------------------------------

export DEBUG=false

while getopts ":du:r:D:l:t:U:h:" opt; do
	case "$opt" in
	d) export DEBUG=true ;;
	u) export USER_PASSWORD="$OPTARG" ;;
	r) export ROOT_PASSWORD="$OPTARG" ;;
	D) export ROOT_DISK="$OPTARG" ;;
	l) export LUKS_PASSWORD="$OPTARG" ;;
	t) export TIMEZONE="$OPTARG" ;;
	U) export USERNAME="$OPTARG" ;;
	h) export HOSTNAME="$OPTARG" ;;
	:)
		echo "Error: la opción -$OPTARG requiere un argumento" >&2
		exit 1
		;;
	\?)
		echo "Error: opción inválida -$OPTARG" >&2
		exit 1
		;;
	esac
done

shift $((OPTIND - 1))

#-------------------------------------------------------------------------------

if [ ! -d /sys/firmware/efi ]; then
	echo "El instalador solo soporta sistemas UEFI" >&2
	exit 1
fi

grep ubuntu /etc/pacman.d/gnupg/gpg.conf ||
	echo 'keyserver hkp://keyserver.ubuntu.com' |
	sudo /usr/bin/tee -a /etc/pacman.d/gnupg/gpg.conf >/dev/null

sudo /usr/bin/pacman -Sy archlinux-keyring --noconfirm
sudo /usr/bin/pacman -Sc --noconfirm
sudo /usr/bin/pacman -S --noconfirm --needed \
	parted libnewt xkeyboard-config bc git lvm2

if [ -d ./installer ]; then
	REPO_CLONE_DIR="$PWD"
	cd ./installer || exit 1
else
	git clone --depth 1 "$REPO_URL.git" $REPO_CLONE_DIR
	cd $REPO_CLONE_DIR/installer || exit 1
fi

export REPO_CLONE_DIR

sudo env \
	DEBUG="$DEBUG" \
	USER_PASSWORD="$USER_PASSWORD" \
	ROOT_PASSWORD="$ROOT_PASSWORD" \
	ROOT_DISK="$ROOT_DISK" \
	TIMEZONE="$TIMEZONE" \
	USERNAME="$USERNAME" \
	HOSTNAME="$HOSTNAME" \
	./stage1.sh
