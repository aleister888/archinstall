#!/bin/bash
# shellcheck disable=SC2068

# Auto-instalador para Arch Linux (Parte 1)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# - Pasa como variables los siguientes parámetros al siguiente script:
#   - Nombre del usuario regular ($USERNAME)
#   - DPI de la pantalla ($FINAL_DPI)
#   - Zona horaria del sistema ($SYSTEM_TIMEZONE)
#   - Nombre del disco utilizado ($ROOT_DISK)
#   - Nombre de la partición principal ($ROOT_PART_NAME)
#   - Nombre de la partición desencriptada abierta ($CRYPT_NAME)
#   - Nombre del grupo LVM ($VG_NAME)
#   - Nombre del host ($HOSTNAME)
#   - Driver de vídeo a usar ($GRAPHIC_DRIVER)
#   - Variables con el software opcional elegido
#     - $CHOSEN_AUDIO_PROD, $CHOSEN_LATEX, $CHOSEN_MUSIC, $CHOSEN_VIRT

whip_msg() {
	whiptail --backtitle "$REPO_URL" --title "$1" --msgbox "$2" 10 60
}

whip_yes() {
	whiptail --backtitle "$REPO_URL" --title "$1" --yesno "$2" 10 60
}

whip_menu() {
	local TITLE=$1
	local MENU=$2
	shift 2
	whiptail --backtitle "$REPO_URL" \
		--title "$TITLE" --menu "$MENU" 15 60 5 $@ 3>&1 1>&2 2>&3
}

whip_input() {
	local TITLE=$1
	local INPUTBOX=$2
	whiptail --backtitle "$REPO_URL" \
		--title "$TITLE" --inputbox "$INPUTBOX" \
		10 60 3>&1 1>&2 2>&3
}

echo_msg() {
	clear
	echo "$1"
	sleep 1
}

cancel_installation() {
	whip_yes "Cancelar" "¿Deseas cancelar la instalación?" && exit 1
}

# Muestra como quedarían las particiones de nuestra instalación para confirmar
# los cambios. También prepara las variables para formatear los discos
scheme_show() {
	local SCHEME # Variable con el esquema de particiones completo
	BOOT_PART=   # Partición de arranque
	ROOT_PART=   # Partición con el sistema

	# Definimos el nombre de las particiones de nuestro disco principal
	# (Los NVME tienen un sistema de nombrado distinto)
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

	# Creamos el esquema que whiptail nos mostrará
	SCHEME="
/dev/$ROOT_DISK [$(lsblk -dn -o size /dev/"$ROOT_DISK")]
├── /dev/$BOOT_PART (/boot)
└── /dev/$ROOT_PART (LUKS)
    └── LVM
        ├── SWAP
        └── /
"

	# Mostramos el esquema para confirmar los cambios
	if ! whiptail \
		--backtitle "$REPO_URL" \
		--title "Confirmar particionado" \
		--yesno "$SCHEME" 15 60; then
		cancel_installation
	fi
}

# Función para elegir como se formatearán nuestros discos
scheme_setup() {
	while true; do
		while true; do
			ROOT_DISK=$(
				whip_menu "Discos disponibles" \
					"Selecciona un disco para la instalación:" \
					"$(lsblk -dn -o name,size | tr '\n' ' ')"
			) && break
		done

		# Confirmamos los cambios
		if scheme_show; then
			return # Salir del bucle si se confirman los cambios
		else
			whip_msg "ERROR" "Error al confirmar el esquema de particiones ¿Cancelo el usuario la operación?"
		fi
	done
}

# Encriptar el disco duro
part_encrypt() {
	local DISPLAY_NAME="$1"
	local DEVICE="$2"
	local DECRYPTED_NAME="$3"
	local LUKS_PASSWORD
	while true; do
		LUKS_PASSWORD=$(
			get_password "Entrada de contraseña" "Confirmación de contraseña" \
				"Introduce la contraseña de encriptación del disco $DISPLAY_NAME:" \
				"Re-introduce la contraseña de encriptación del disco $DISPLAY_NAME:"
		)
		echo -ne "$LUKS_PASSWORD" | cryptsetup \
			--type luks2 \
			--verify-passphrase -q luksFormat "/dev/$DEVICE" && break

		# Cambiar la contraseña si hubo un error
		whip_msg "LUKS" "Hubo un error, deberá introducir la contraseña otra vez"
	done

	echo -ne "$LUKS_PASSWORD" | cryptsetup open "/dev/$DEVICE" "$DECRYPTED_NAME" && return
}

disk_setup() {
	local LVM_DEVICE=
	ROOT_PART_NAME="$ROOT_PART"

	# Nombres aleatorios para poder usar el instalado desde una instalación ya existente
	CRYPT_NAME=$(tr -dc 'a-zA-Z' </dev/urandom | fold -w 5 | head -n 1)
	VG_NAME=$(tr -dc 'a-zA-Z' </dev/urandom | fold -w 5 | head -n 1)

	# Borramos la firma del disco
	wipefs --all "/dev/$ROOT_DISK"
	# Creamos nuestra tabla de particionado y las dos particiones necesarias
	printf "label: gpt\n,1G,U\n,,\n" | sfdisk "/dev/$ROOT_DISK"

	# Formateamos la primera partición como EFI
	mkfs.fat -F32 "/dev/$BOOT_PART"

	# Encriptamos la partición
	part_encrypt "/" "$ROOT_PART" "$CRYPT_NAME"
	LVM_DEVICE="/dev/mapper/$CRYPT_NAME"

	# Inicializamos LVM
	pvcreate "$LVM_DEVICE"
	vgcreate "$VG_NAME" "$LVM_DEVICE"

	lvcreate -L 16G -n swap "$VG_NAME"
	lvcreate -l 100%FREE -n root "$VG_NAME"

	ROOT_PART="$VG_NAME/root"

	mkswap "/dev/$VG_NAME/swap"
	swapon "/dev/$VG_NAME/swap"

	# Formateamos y montamos nuestras particiones
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
basestrap_install() {
	local BASESTRAP_PACKAGES

	BASESTRAP_PACKAGES="base linux linux-headers linux-firmware mkinitcpio"

	BASESTRAP_PACKAGES+=" cronie lvm2 cups networkmanager cryptsetup acpid"

	# Instalamos los paquetes del grupo base-devel manualmente para luego
	# poder borrar sudo facilmente. (Si en su lugar instalamos el grupo,
	# luego será más complicado desinstalarlo)
	BASESTRAP_PACKAGES+=" autoconf automake bison debugedit fakeroot flex"
	BASESTRAP_PACKAGES+=" gc gcc groff guile libisl libmpc libtool m4 make"
	BASESTRAP_PACKAGES+=" patch pkgconf texinfo which"

	BASESTRAP_PACKAGES+=" efibootmgr grub wpa_supplicant btrfs-progs"

	# Con estos paquetes podemos usar lspci y lsusb para dectectar si hay algún
	# dispositivo bluetooth y debemos instalar bluez
	BASESTRAP_PACKAGES+=" pciutils usbutils"

	BASESTRAP_PACKAGES+=" git libjpeg-turbo dosfstools freetype2 dialog"
	BASESTRAP_PACKAGES+=" wget libnewt neovim opendoas"

	# Instalamos pipewire para evitar conflictos (p.e. se isntala jack2 y no
	# pipewire-jack). Los paquetes para 32 bits se instalarán una vez
	# activados el repo multilib de Arch Linux (s3)
	BASESTRAP_PACKAGES+=" pipewire-pulse wireplumber pipewire pipewire-alsa"
	BASESTRAP_PACKAGES+=" pipewire-audio pipewire-jack"

	# Instalamos go y sudo para poder compilar yay más adelante (s3)
	BASESTRAP_PACKAGES+=" go sudo"

	# Para procesar los .json con los paquetes a instalar
	BASESTRAP_PACKAGES+=" jq"

	# Añadimos el paquete con el microcódigo de CPU correspodiente
	local MANUFACTURER
	MANUFACTURER=$(
		grep vendor_id /proc/cpuinfo | awk '{print $3}' | head -1
	)
	if [ "$MANUFACTURER" == "GenuineIntel" ]; then
		BASESTRAP_PACKAGES+=" intel-ucode"
	elif [ "$MANUFACTURER" == "AuthenticAMD" ]; then
		BASESTRAP_PACKAGES+=" amd-ucode"
	fi

	# Si el dispositivo tiene bluetooth, instalaremos blueman
	if echo "$(
		lspci
		lsusb
	)" | grep -i bluetooth; then
		BASESTRAP_PACKAGES+=" blueman"
	fi

	# shellcheck disable=SC2086
	while true; do
		pacstrap /mnt $BASESTRAP_PACKAGES && break
	done
}

# Calcular el DPI
calculate_dpi() {
	local RESOLUTION SIZE WIDTH HEIGHT FACT DISPLAY_DPI

	# Selección de resolución del monitor
	while true; do
		RESOLUTION=$(
			whip_menu "Resolucion del Monitor" \
				"Seleccione la resolucion de su monitor:" \
				"720p" "HD" "1080p" "Full-HD" "1440p" "QHD" "2160p" "4K"
		)

		# Si se cancela o está vacío, preguntar si quiere salir
		if [ -z "$RESOLUTION" ]; then
			cancel_installation
		else
			break
		fi
	done

	# Selección del tamaño del monitor en pulgadas (diagonal)
	while true; do
		SIZE=$(
			whip_menu "Tamaño del Monitor" \
				"Seleccione el tamaño de su monitor (en pulgadas):" \
				"14" "Portatil" \
				"15.6" "Portatil" \
				"17" "Portatil" \
				"24" "Escritorio" \
				"27" "Escritorio"
		)

		# Si se cancela o está vacío, preguntar si quiere salir
		if [ -z "$SIZE" ]; then
			cancel_installation
		else
			break
		fi
	done

	# Definimos la resolución elegida
	case $RESOLUTION in
	"720p")
		WIDTH=1280
		HEIGHT=720
		FACT="0.6"
		;;
	"1080p")
		WIDTH=1920
		HEIGHT=1080
		FACT="0.75"
		;;
	"1440p")
		WIDTH=2560
		HEIGHT=1440
		FACT="1"
		;;
	"2160p")
		WIDTH=3840
		HEIGHT=2160
		FACT="1.2"
		;;
	esac

	# Calculamos el DPI
	DISPLAY_DPI=$(
		echo "scale=6; sqrt($WIDTH^2 + $HEIGHT^2) / $SIZE * $FACT" | bc
	)

	# Redondeamos el DPI calculado al entero más cercano
	FINAL_DPI=$(printf "%.0f" "$DISPLAY_DPI")
}

get_password() {
	local PASSWORD_1 PASSWORD_2
	local TITLE_1=$1
	local TITLE_2=$2
	local BOX_1=$3
	local BOX_2=$4

	while true; do

		# Pedir la contraseña la primera vez
		PASSWORD_1=$(
			whiptail --backtitle "$REPO_URL" \
				--title "$TITLE_1" \
				--passwordbox "$BOX_1" \
				10 60 3>&1 1>&2 2>&3
		)

		# Pedir la contraseña una segunda vez
		PASSWORD_2=$(
			whiptail --backtitle "$REPO_URL" \
				--title "$TITLE_2" \
				--passwordbox "$BOX_2" \
				10 60 3>&1 1>&2 2>&3
		)

		# Si ambas contraseñas coinciden devolver el resultado
		if [ "$PASSWORD_1" == "$PASSWORD_2" ] && [ -n "$PASSWORD_1" ]; then
			echo "$PASSWORD_1" && break
		else
			# Mostrar un mensaje de error si las contraseñas no coinciden
			whiptail --backtitle "$REPO_URL" \
				--title "Error" \
				--msgbox "Las contraseñas no coinciden. Inténtalo de nuevo." \
				10 60 3>&1 1>&2 2>&3
		fi

	done
}

# Establecer zona horaria
timezone_set() {
	while true; do
		# Obtener la lista de regiones disponibles
		REGIONS=$(
			find /usr/share/zoneinfo -mindepth 1 -type d \
				-printf "%f\n" | grep -v '^[a-z]\|Etc' | sort -u
		)

		# Crear un array con las regiones
		REGIONS_ARRAY=()
		for REGION in $REGIONS; do
			REGIONS_ARRAY+=("$REGION" "$REGION")
		done

		# Elegir la región
		while true; do
			REGION=$(
				whip_menu "Selecciona una región" \
					"Por favor, elige una región" \
					${REGIONS_ARRAY[@]}
			)

			# Si se cancela o está vacío, preguntar si quiere salir
			if [ -z "$REGION" ]; then
				cancel_installation
			else
				break
			fi
		done

		# Obtener la lista de zonas horarias de la región seleccionada
		TIMEZONES=$(
			find "/usr/share/zoneinfo/$REGION" -mindepth 1 -type f \
				-printf "%f\n" | sort -u
		)

		# Crear un array con las distintas zonas horarias
		TIMEZONES_ARRAY=()
		for TIMEZONE in $TIMEZONES; do
			TIMEZONES_ARRAY+=("$TIMEZONE" "$TIMEZONE")
		done

		# Elegir la zona horaria dentro de la región seleccionada
		while true; do
			TIMEZONE=$(
				whip_menu "Selecciona una zona horaria en $REGION" \
					"Por favor, elige una zona horaria en $REGION:" \
					${TIMEZONES_ARRAY[@]}
			)

			# Si se cancela o está vacío, preguntar si quiere salir
			if [ -z "$TIMEZONE" ]; then
				cancel_installation
			else
				break
			fi
		done

		# Verificar si la zona horaria seleccionada es válida
		if [ -f "/usr/share/zoneinfo/$REGION/$TIMEZONE" ]; then
			break
		else
			whip_msg "Zona horaria no valida" \
				"Zona horaria no valida. Asegúrate de elegir una zona horaria valida."
		fi
	done

	SYSTEM_TIMEZONE="/usr/share/zoneinfo/$REGION/$TIMEZONE"
}

# Elegimos el driver de vídeo
driver_choose() {
	local DRIVER_OPTIONS

	# Opciones posibles
	DRIVER_OPTIONS=(
		"amd" "AMD" "nvidia" "NVIDIA" "intel" "INTEL" "vm" "VM"
	)

	# Elegimos nuestra tarjeta gráfica
	while true; do
		GRAPHIC_DRIVER=$(
			whip_menu "Selecciona tu tarjeta grafica" "Elige una opcion:" \
				${DRIVER_OPTIONS[@]}
		)

		# Si se cancela o está vacío, preguntar si quiere salir
		if [ -z "$GRAPHIC_DRIVER" ]; then
			cancel_installation
		else
			break
		fi
	done

}

packages_choose() {
	while true; do
		VARIABLES=(
			"CHOSEN_AUDIO_PROD"
			"CHOSEN_LATEX"
			"CHOSEN_MUSIC"
			"CHOSEN_VIRT"
		)

		# Reiniciamos las variables si no confirmamos la selección
		for VAR in "${VARIABLES[@]}"; do eval "$VAR=false"; done

		whip_yes "Virtualización" \
			"¿Quieres instalar libvirt para ejecutar máquinas virtuales?" &&
			CHOSEN_VIRT="true"

		whip_yes "Música" \
			"¿Deseas instalar software para manejar tu coleccion de música?" &&
			CHOSEN_MUSIC="true"

		whip_yes "laTeX" \
			"¿Deseas instalar laTeX?" &&
			CHOSEN_LATEX="true"

		whip_yes "DAW" \
			"¿Deseas instalar software de produccion de audio?" &&
			CHOSEN_AUDIO_PROD="true"

		# Confirmamos la selección de paquetes a instalar (o no)
		if packages_show; then
			break
		else
			whip_msg "Operación cancelada" \
				"Se te volverá a preguntar que software desea instalar"
		fi
	done
}

# Elegimos que paquetes instalar
packages_show() {
	local SCHEME # Variable con la lista de paquetes a instalar
	SCHEME="Se instalará:\n"
	[ "$CHOSEN_AUDIO_PROD" == "true" ] && SCHEME+="    Softw. Prod. Musical\n"
	[ "$CHOSEN_MUSIC" == "true" ] && SCHEME+="    Softw. Gestión de Música\n"
	[ "$CHOSEN_LATEX" == "true" ] && SCHEME+="    laTeX\n"
	[ "$CHOSEN_VIRT" == "true" ] && SCHEME+="    libvirt\n"

	whiptail --backtitle "$REPO_URL" \
		--title "Confirmar paquetes" \
		--yesno "$SCHEME" 15 60
}

##########
# SCRIPT #
##########

# Elegimos como se formatearán nuestros discos
scheme_setup

# Formateamos, creamos la swap y montamos los discos
disk_setup

# Calculamos el DPI
calculate_dpi

ROOT_PASSWORD=$(
	get_password "Entrada de contraseña" "Confirmación de contraseña" \
		"Introduce la contraseña del superusuario:" \
		"Re-introduce la contraseña del superusuario:"
)

while true; do
	USERNAME=$(
		whiptail --backtitle "$REPO_URL" \
			--inputbox "Por favor, ingresa el nombre del usuario:" \
			10 60 3>&1 1>&2 2>&3
	)

	# Si se cancela o está vacío, preguntar si quiere salir
	if [ -z "$USERNAME" ]; then
		cancel_installation
	else
		break
	fi
done

USER_PASSWORD=$(
	get_password "Entrada de contraseña" "Confirmación de contraseña" \
		"Introduce la contraseña del usuario $USERNAME:" \
		"Re-introduce la contraseña del usuario $USERNAME:"
)

timezone_set

while true; do
	HOSTNAME=$(
		whip_input "Configuracion de hostname" \
			"Por favor, introduce el nombre que deseas darle al equipo:"
	)

	# Si se cancela o está vacío, preguntar si quiere salir
	if [ -z "$HOSTNAME" ]; then
		cancel_installation
	else
		break
	fi
done

# Elegimos el driver de video y lo guardamos en la variable $GRAPHIC_DRIVER
driver_choose

# Elegimos que software opcional instalar
packages_choose

# Avisamos al usuario de que ya puede relajarse y dejar que el haga su trabajo
whip_msg "Hora del cafe" \
	"El instalador ya tiene toda la información necesaria, puedes dejar el ordenador desatendido. La instalacion tomara 30-45min aproximadamente."

# Instalamos paquetes en la nueva instalación
basestrap_install

# Creamos el fstab
genfstab -U /mnt >/mnt/etc/fstab

# Montamos los directorios necesarios para el chroot
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
	USERNAME=$USERNAME \
	FINAL_DPI=$FINAL_DPI \
	SYSTEM_TIMEZONE=$SYSTEM_TIMEZONE \
	ROOT_DISK=$ROOT_DISK \
	ROOT_PART_NAME=$ROOT_PART_NAME \
	CRYPT_NAME=$CRYPT_NAME \
	VG_NAME=$VG_NAME \
	HOSTNAME=$HOSTNAME \
	GRAPHIC_DRIVER=$GRAPHIC_DRIVER \
	CHOSEN_VIRT=$CHOSEN_VIRT \
	CHOSEN_MUSIC=$CHOSEN_MUSIC \
	CHOSEN_LATEX=$CHOSEN_LATEX \
	CHOSEN_AUDIO_PROD=$CHOSEN_AUDIO_PROD

	chown $USERNAME:$USERNAME -R \
	   /home/$USERNAME/.dotfiles
	cd /home/$USERNAME/.dotfiles/installer

	./stage2.sh
"
