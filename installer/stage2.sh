#!/bin/bash
# shellcheck disable=SC2154

# Auto-instalador para Arch Linux (Parte 2)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# Esta parte del script se ejecuta ya dentro de la instalación (chroot).

pacinstall() {
	pacman -Sy --noconfirm --disable-download-timeout --needed "$@"
}

service_add() {
	systemctl enable "$1"
}

# Instalamos GRUB
install_grub() {
	local -r SWAP_UUID=$(lsblk -nd -o UUID /dev/mapper/"$VG_NAME-swap")

	# Obtenemos el nombre del dispositivo donde se aloja la partición boot
	case "$ROOT_DISK" in
	*"nvme"*)
		BOOT_DRIVE="${ROOT_DISK%p[0-9]}"
		;;
	*)
		BOOT_DRIVE="${ROOT_DISK%[0-9]}"
		;;
	esac

	# Instalar GRUB
	grub-install --target=x86_64-efi --efi-directory=/boot \
		--recheck "$BOOT_DRIVE"

	grub-install --target=x86_64-efi --efi-directory=/boot \
		--removable --recheck "$BOOT_DRIVE"

	# Le indicamos a GRUB el UUID de la partición encriptada y desencriptada.
	local -r CRYPT_ID=$(lsblk -nd -o UUID /dev/"$ROOT_PART_NAME")
	local -r ROOT_UUID=$(lsblk -nd -o UUID /dev/mapper/"$VG_NAME-root")
	echo GRUB_ENABLE_CRYPTODISK=y >>/etc/default/grub

	local GRUB_BOOT_OPTIONS
	GRUB_BOOT_OPTIONS="  cryptdevice=UUID=$CRYPT_ID:cryptroot"
	GRUB_BOOT_OPTIONS+=" root=UUID=$ROOT_UUID"
	GRUB_BOOT_OPTIONS+=" resume=UUID=$SWAP_UUID"
	GRUB_BOOT_OPTIONS+=" modprobe.blacklist=nouveau"
	GRUB_BOOT_OPTIONS+=" net.ifnames=0"
	GRUB_BOOT_OPTIONS+=" snd_usb_audio.lowlatency=0"
	GRUB_BOOT_OPTIONS+=" snd_usb_audio.implicit_fb=1"

	sed -i "s/\(^GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\"/\1$GRUB_BOOT_OPTIONS\"/" /etc/default/grub

	# Crear el archivo de configuración
	grub-mkconfig -o /boot/grub/grub.cfg
}

# Definimos el nombre de nuestra máquina y creamos el archivo hosts
hostname_config() {
	echo "$HOSTNAME" >/etc/hostname

	# Este archivo hosts bloquea el acceso a sitios maliciosos
	timeout -k 1s 3s curl -s --head --request GET "https://www.gnu.org/" >/dev/null 2>&1 &&
		curl -o /etc/hosts "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

	cat <<-EOF | tee -a /etc/hosts
		127.0.0.1 localhost
		127.0.0.1 $HOSTNAME.localdomain $HOSTNAME
		127.0.0.1 localhost.localdomain
		127.0.0.1 local
	EOF
}

# Configurar pacman
repos_conf() {
	# Activar multilib
	sed -i '/#\[multilib\]/{s/^#//;n;s/^.//}' /etc/pacman.conf
	pacman -Sy --noconfirm

	pacinstall reflector

	# Escoger mirrors más rápidos de los repositorios de Arch
	reflector --verbose --fastest 10 --age 6 --protocol https,ftp \
		--connection-timeout 1 --download-timeout 1 \
		--threads "$(nproc)" \
		--save /etc/pacman.d/mirrorlist

	# Configurar cronie para actualizar automáticamente los mirrors de Arch
	cat <<-EOF >/etc/crontab
		SHELL=/bin/bash
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

		# Escoger los mejores repositorios para Arch Linux
		@hourly root ping gnu.org -c 1 && reflector --latest 10 --protocol https,ftp --connection-timeout 1 --download-timeout 1 --sort rate --save /etc/pacman.d/mirrorlist
	EOF

	# Añadir Chaotic AUR
	while ! pacman -Q chaotic-keyring chaotic-mirrorlist >/dev/null 2>&1; do
		pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
		pacman-key --lsign-key 3056513887B78AEB
		pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
		pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
	done

	cat <<-EOF >>/etc/pacman.conf

		[chaotic-aur]
		Include = /etc/pacman.d/chaotic-mirrorlist
	EOF

	pacman -Sy
}

# Cambiar la codificación del sistema a español
genlocale() {
	sed -i -E 's/^#(en_US\.UTF-8 UTF-8)/\1/' /etc/locale.gen
	sed -i -E 's/^#(es_ES\.UTF-8 UTF-8)/\1/' /etc/locale.gen
	locale-gen
	echo "LANG=es_ES.UTF-8" >/etc/locale.conf
}

# Configurar la creación del initramfs
mkinitcpio_conf() {
	local -r MKINITCPIO_CONF="/etc/mkinitcpio.conf"
	local MODULES="vfat usb_storage btusb nvme"
	local HOOKS="base udev autodetect microcode modconf kms keyboard keymap consolefont block lvm2 encrypt filesystems resume fsck"
	sed -i "s/^MODULES=.*/MODULES=($MODULES)/" "$MKINITCPIO_CONF"
	sed -i "s/^HOOKS=.*/HOOKS=($HOOKS)/" "$MKINITCPIO_CONF"
}

##########
# SCRIPT #
##########

# Establecer la zona horaria
ln -sf "$SYSTEM_TIMEZONE" /etc/localtime
# Sincronizar reloj del hardware con la zona horaria
hwclock --systohc

# Configurar el servidor de claves y limpiar la cache
grep ubuntu /etc/pacman.d/gnupg/gpg.conf ||
	echo 'keyserver hkp://keyserver.ubuntu.com' |
	tee -a /etc/pacman.d/gnupg/gpg.conf >/dev/null
pacman -Sc --noconfirm
pacman-key --populate && pacman-key --refresh-keys

# Configurar pacman
sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

if { lspci | grep -qi bluetooth || lsusb | grep -qi bluetooth; }; then
	pacinstall bluez bluez-utils bluez-obex
	service_add bluetooth
fi

# Instalamos grub
install_grub

# Definimos el nombre de nuestra máquina y creamos el archivo hosts
hostname_config

# Configurar pacman
repos_conf

# Configurar la codificación del sistema
genlocale

# Agregamos los módulos y ganchos imprescindibles al initramfs
mkinitcpio_conf
# Regeneramos el initramfs
mkinitcpio -P

# Actualizamos la configuración de GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Activamos servicios
service_add NetworkManager
service_add cronie
service_add acpid
service_add cups

# Configuramos sudo temporalmente para stage3.sh
cp /etc/sudoers /etc/sudoers.bak
echo "root ALL=(ALL:ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers

su "$USERNAME" -c "cd /home/$USERNAME/.dotfiles/installer && ./stage3.sh"
