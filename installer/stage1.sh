#!/bin/bash
# shellcheck disable=SC2068,SC2155

# Auto-instalador para Arch Linux (Parte 1)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# - Pasa como variables los siguientes parámetros al siguiente script:
#   - ¿Script en modo debugging? ($DEBUG)
#   - Nombre del usuario regular ($USERNAME)
#   - Zona horaria del sistema ($TIMEZONE)
#   - Nombre del disco utilizado ($ROOT_DISK)
#   - Nombre de la partición principal ($ROOT_PART_NAME)
#   - Nombre de la partición desencriptada abierta ($CRYPT_NAME)
#   - Nombre del grupo LVM ($VG_NAME)
#   - Nombre del host ($HOSTNAME)

source "$REPO_CLONE_DIR/assets/shell/shell-utils"

whip_msg() {
	whiptail --backtitle "$REPO_URL" --title "$1" --msgbox "$2" 15 60 \
		3>&1 1>&2 2>&3 || { 3>&- return 1; }
}

whip_yes() {
	whiptail --backtitle "$REPO_URL" --title "$1" --yesno "$2" 15 60 \
		3>&1 1>&2 2>&3 || { 3>&- return 1; }
}

whip_password() {
	whiptail --backtitle "$REPO_URL" --title "$1" --passwordbox "$2" 15 60 \
		3>&1 1>&2 2>&3 || { 3>&- return 1; }
}

whip_menu() {
	local TITLE=$1 MENU=$2
	shift 2
	whiptail --backtitle "$REPO_URL" --title "$TITLE" --menu "$MENU" 15 60 8 $@ \
		3>&1 1>&2 2>&3 || { 3>&- return 1; }
}

whip_input() {
	local TITLE=$1 INPUTBOX=$2
	whiptail --backtitle "$REPO_URL" --title "$TITLE" --inputbox "$INPUTBOX" 15 60 \
		3>&1 1>&2 2>&3 || { 3>&- return 1; }
}

ask_cancel_install() {
	whip_yes "Cancelar" "¿Deseas cancelar la instalación?" && exit 1
	return 0
}

wait_return() {
	[ "$DEBUG" = true ] && read -rp "Presiona Enter para continuar..."
}

# Muestra como quedarían las particiones de nuestra instalación para confirmar
# los cambios. También prepara las variables para formatear los discos
#-------------------------------------------------------------------------------

disk_scheme_show() {
	local DISK_SIZE
	local SCHEME_PREVIEW
	DISK_SIZE="$(lsblk -dn -o size /dev/"$ROOT_DISK")"
	SCHEME_PREVIEW=$(
		cat <<-EOF
			/dev/$ROOT_DISK [$DISK_SIZE]
			├── /boot (/dev/$BOOT_PART)
			└── LUKS  (/dev/$ROOT_PART)
			    └── LVM
			        ├── SWAP
			        └── /
		EOF
	)
	if ! whip_yes "Confirmar particionado" "$SCHEME_PREVIEW"; then
		ask_cancel_install
	fi
}

disk_scheme_setup() {
	while true; do
		[ -z "$ROOT_DISK" ] &&
			while true; do
				ROOT_DISK=$(
					whip_menu "Discos disponibles" \
						"Selecciona un disco para la instalación:" \
						"$(lsblk -dn -o name,size | tr '\n' ' ')"
				) && break
			done

		case "$ROOT_DISK" in
		*"nvme"* | *"mmcblk"*)
			BOOT_PART="$ROOT_DISK"p1
			ROOT_PART="$ROOT_DISK"p2
			;;
		*)
			BOOT_PART="$ROOT_DISK"1
			ROOT_PART="$ROOT_DISK"2
			;;
		esac

		{ [ "$DISK_NO_CONFIRM" = true ] || disk_scheme_show; } && return

		unset ROOT_DISK
		whip_msg "ERROR" "Error al confirmar el esquema de particiones"
	done
}

disk_encrypt() {
	local DISPLAY_NAME="$1"
	local DEVICE="$2"
	local DECRYPTED_NAME="$3"
	while true; do
		[ -z "$LUKS_PASSWORD" ] &&
			LUKS_PASSWORD=$(
				get_password "Entrada de contraseña" "Confirmación de contraseña" \
					"Introduce la contraseña de encriptación del disco $DISPLAY_NAME:" \
					"Re-introduce la contraseña de encriptación del disco $DISPLAY_NAME:"
			)
		echo -ne "$LUKS_PASSWORD" | cryptsetup \
			--type luks2 \
			--verify-passphrase -q luksFormat "/dev/$DEVICE" && break

		unset LUKS_PASSWORD

		wait_return
		whip_msg "LUKS" "Error al encriptar el disco, introduce otra contraseña"
	done

	echo -ne "$LUKS_PASSWORD" | cryptsetup open "/dev/$DEVICE" "$DECRYPTED_NAME" && return
}

disk_setup() {
	local LVM_DEVICE=
	ROOT_PART_NAME="$ROOT_PART" # Definido en disk_scheme_setup

	# Nombres aleatorios para poder usar el instalador desde una instalación ya
	# existente sin conflictos
	CRYPT_NAME=$(openssl rand -base64 4 | tr -dc 'a-zA-Z' | head -c5)
	VG_NAME=$(openssl rand -base64 4 | tr -dc 'a-zA-Z' | head -c5)

	# Borramos la firma del disco y creamos una nueva tabla con dos particiones
	wipefs --all "/dev/$ROOT_DISK"
	printf "label: gpt\n,1G,U\n,,\n" | sfdisk "/dev/$ROOT_DISK"

	mkfs.fat -F32 "/dev/$BOOT_PART"

	disk_encrypt "/" "$ROOT_PART" "$CRYPT_NAME"
	LVM_DEVICE="/dev/mapper/$CRYPT_NAME"

	pvcreate "$LVM_DEVICE"
	vgcreate "$VG_NAME" "$LVM_DEVICE"
	lvcreate -L 16G -n swap "$VG_NAME"
	lvcreate -l 100%FREE -n root "$VG_NAME"
	ROOT_PART="$VG_NAME/root"

	mkswap "/dev/$VG_NAME/swap"
	swapon "/dev/$VG_NAME/swap"

	mkfs.btrfs -f "/dev/$ROOT_PART"

	mount "/dev/$ROOT_PART" /mnt
	btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@home
	btrfs subvolume create /mnt/@images
	umount -R /mnt

	mount -t btrfs \
		-o noatime,compress=zstd:1,autodefrag,subvol=@ \
		"/dev/$ROOT_PART" /mnt

	mkdir -p /mnt/{home,var/lib/libvirt/images}

	mount -t btrfs \
		-o noatime,compress=zstd:1,autodefrag,subvol=@home \
		"/dev/$ROOT_PART" /mnt/home
	mount -t btrfs \
		-o noatime,autodefrag,subvol=@images \
		"/dev/$ROOT_PART" /mnt/var/lib/libvirt/images

	mkdir /mnt/boot
	mount "/dev/$BOOT_PART" /mnt/boot
}

# Instalar paquetes con basestrap
# Ejecutamos basestrap en un bucle hasta que se ejecute correctamente
# porque el comando no tiene la opción --disable-download-timeout.
# Lo que podría hacer que la operación falle con conexiones muy lentas.
#-------------------------------------------------------------------------------

basestrap_packages_install() {
	local BASESTRAP_PACKAGES
	local MANUFACTURER=$(grep vendor_id /proc/cpuinfo | awk '{print $3}' | head -1)

	mapfile -t BASESTRAP_PACKAGES < <(
		jq -r '.[] | .[]' < <(# Importamos el json sin los comentarios
			cat "$REPO_CLONE_DIR/assets/packages/installer.json" | grep -v "[ ]*//"
		)
	)

	if [ "$MANUFACTURER" == "GenuineIntel" ]; then
		BASESTRAP_PACKAGES+=("intel-ucode")
	elif [ "$MANUFACTURER" == "AuthenticAMD" ]; then
		BASESTRAP_PACKAGES+=("amd-ucode")
	fi

	has_bluetooth_device && BASESTRAP_PACKAGES+=("blueman")

	while true; do
		if pacstrap /mnt ${BASESTRAP_PACKAGES[@]}; then break; else wait_return; fi
	done
}

# Establecer zona horaria
#-------------------------------------------------------------------------------

list() {
	local DIR_PATH="$1"
	local TYPE="$2"
	find "$DIR_PATH" -mindepth 1 -type "$TYPE" \
		-printf "%f\n" | grep -v '^[a-z]\|Etc' | sort -u
}
select_from_list() {
	local DIR_PATH="$1" TYPE="$2" MSG="$3" SELECTION
	local -a ARRAY

	while read -r ENTRY; do
		ARRAY+=("$ENTRY" "$ENTRY")
	done < <(list "$DIR_PATH" "$TYPE" "$FILTER")

	while true; do
		SELECTION=$(
			whip_menu "Selecciona una $MSG" "Elige una $MSG" ${ARRAY[@]}
		)

		[ -n "$SELECTION" ] && break
		ask_cancel_install
	done

	echo "$SELECTION"
}
get_timezone() {
	while true; do
		if [ -z "$TIMEZONE" ]; then # TIMEZONE puede estar asignado desde install.sh
			REGION=$(select_from_list /usr/share/zoneinfo d "región")
			TIMEZONE=$(select_from_list "/usr/share/zoneinfo/$REGION" f "zona horaria")
			TIMEZONE="$REGION/$TIMEZONE"
		fi

		# Verificar si la zona horaria seleccionada es válida
		[ -f "/usr/share/zoneinfo/$TIMEZONE" ] && break

		unset REGION TIMEZONE
		wait_return
		whip_msg "Zona horaria no valida" \
			"Zona horaria no valida. Asegúrate de elegir una zona horaria valida."
	done
}

#-------------------------------------------------------------------------------

get_password() {
	local PASS_ENTERED PASS_CONFIRM
	local TITLE_ENTERED=$1 TITLE_CONFIRM=$2 BOX_ENTERED=$3 BOX_CONFIRM=$4

	while true; do
		PASS_ENTERED=$(whip_password "$TITLE_ENTERED" "$BOX_ENTERED")
		PASS_CONFIRM=$(whip_password "$TITLE_CONFIRM" "$BOX_CONFIRM")

		if [ "$PASS_ENTERED" == "$PASS_CONFIRM" ] && [ -n "$PASS_ENTERED" ]; then
			echo "$PASS_ENTERED" && return
		else
			whip_yes "Error" "Las contraseñas no coinciden. Inténtalo de nuevo." ||
				ask_cancel_install
		fi
	done
}

get_root_password() {
	[ -n "$ROOT_PASSWORD" ] && return
	ROOT_PASSWORD=$(
		get_password "Entrada de contraseña" "Confirmación de contraseña" \
			"Introduce la contraseña del superusuario:" \
			"Re-introduce la contraseña del superusuario:"
	)
}

get_user_password() {
	[ -n "$USER_PASSWORD" ] && return
	USER_PASSWORD=$(
		get_password "Entrada de contraseña" "Confirmación de contraseña" \
			"Introduce la contraseña del usuario $USERNAME:" \
			"Re-introduce la contraseña del usuario $USERNAME:"
	)
}

#-------------------------------------------------------------------------------

confirm_input() {
	whip_yes "Confirmación" "Estas seguro de que quiere que el $1 sea: $2"
}

get_username() {
	[ -n "$USERNAME" ] && return
	while true; do
		USERNAME=$(whip_input "Nombre usuario" "Ingresa el nombre del usuario:") ||
			ask_cancel_install

		[ -n "$USERNAME" ] && confirm_input "nombre de usuario" "$USERNAME" && break
	done
}

get_hostname() {
	[ -n "$HOSTNAME" ] && return
	while true; do
		HOSTNAME=$(whip_input "Configuracion de hostname" "Introduce el nombre del equipo:") ||
			ask_cancel_install

		[ -n "$HOSTNAME" ] && confirm_input "hostname" "$HOSTNAME" && break
	done
}

#-------------------------------------------------------------------------------

get_root_password
get_username
get_user_password
get_timezone
get_hostname

disk_scheme_setup
disk_setup

basestrap_packages_install

genfstab -U /mnt >/mnt/etc/fstab

for DIR in dev proc sys run; do
	mount --rbind /$DIR /mnt/$DIR
	mount --make-rslave /mnt/$DIR
done

arch-chroot /mnt sh -c "
	useradd -m -G wheel,lp $USERNAME
	yes $ROOT_PASSWORD | passwd
	yes $USER_PASSWORD | passwd $USERNAME
"

# Copiamos el repositorio a la nueva instalación
cp -r "$(dirname "$0")/.." "/mnt/home/$USERNAME/.dotfiles"

# Corregimos el propietario del repositorio copiado y ejecutamos la siguiente
# parte del script pasandole las variables correspondientes.
arch-chroot /mnt sh -c "
	export \
	DEBUG=$DEBUG \
	USERNAME=$USERNAME \
	TIMEZONE=$TIMEZONE \
	ROOT_DISK=$ROOT_DISK \
	ROOT_PART_NAME=$ROOT_PART_NAME \
	CRYPT_NAME=$CRYPT_NAME \
	VG_NAME=$VG_NAME \
	HOSTNAME=$HOSTNAME

	chown $USERNAME:$USERNAME -R \
	   /home/$USERNAME/.dotfiles
	cd /home/$USERNAME/.dotfiles/installer

	./stage2.sh
" || true # Evitar repotar errores en cascada
