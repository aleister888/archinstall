#!/bin/bash
# shellcheck disable=SC2068
# shellcheck disable=SC2154

# Auto-instalador para Arch Linux (Parte 3)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# Importamos todos los componentes en los que se separa el script
PATH="$PATH:$(find ~/.dotfiles/installer/modules -type d | paste -sd ':' -)"

# Instalar paquetes con yay
yayinstall() {
	yay -Sy --noconfirm --needed "$@"
}

PACKAGES=()
DRIVERS_VID=()
driver_add() {
	case $GRAPHIC_DRIVER in
	vm) DRIVERS_VID+=("vulkan-virtio" "lib32-vulkan-virtio") ;;
	intel) DRIVERS_VID+=(
		"lib32-libva-intel-driver"
		"lib32-vulkan-intel"
		"libva-intel-driver"
		"vulkan-intel"
	) ;;
	amd) DRIVERS_VID+=(
		"mesa"
		"lib32-mesa"
		"vulkan-radeon"
		"lib32-vulkan-radeon"
	) ;;
	nvidia) DRIVERS_VID+=(
		"dkms"
		"nvidia-dkms"
		"nvidia-utils"
		"lib32-nvidia-utils"
		"libva-mesa-driver"
		"libva-nvidia-driver"
		"nvidia-prime"
		"opencl-nvidia"
	) ;;
	esac
}

arr_packages() {
	# Guardamos nuestros paquetes a instalar en un array
	mapfile -t TMP_PACKAGES < <(
		find "$HOME/.dotfiles/assets/packages" -name '*.hjson' \
			-exec sh -c 'hjson -j "$1" | jq -r ".[] | .[]" ' _ {} \;
	)
	PACKAGES=("${TMP_PACKAGES[@]}" "${DRIVERS_VID[@]}")
}

# Descargar los archivos de diccionario
vim_spell_download() {
	mkdir -p "$HOME/.local/share/nvim/site/spell/"
	wget "https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.spl" \
		-q -O "$HOME/.local/share/nvim/site/spell/es.utf-8.spl"
	wget "https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.sug" \
		-q -O "$HOME/.local/share/nvim/site/spell/es.utf-8.sug"
}

# Crear el directorio /.Trash con permisos adecuados
trash_dir() {
	sudo /usr/bin/mkdir --parent /.Trash
	sudo /usr/bin/chmod a+rw /.Trash
	sudo /usr/bin/chmod +t /.Trash
}

##########
# SCRIPT #
##########

###############################
# Instalación de los paquetes #
###############################

# Antes de instalar los paquetes, configuramos makepkg para
# usar todos los núcleos durante la compilación
sudo /usr/bin/sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

# Instalamos yay (https://aur.archlinux.org/packages/yay)
yay-install

# Añadimos los drivers de video a la lista de paquetes
# TODO: Re-evaluar en cada iteración del bucle para instalar los paquetes
driver_add

# Instalamos todos los paquetes a la vez
while true; do
	# En cada iteración se vuelven a leer los archivos con los paquetes a instalar
	# De este modo en caso de error podemos intervenir más facilmente
	arr_packages

	yayinstall "${PACKAGES[@]}" && break

	echo "La instalación de los paquetes falló. Por favor revisa tu conexión."

	# Preguntamos al usuario como continuar si hubo un fallo
	while true; do
		read -p "¿Deseas intentar la instalación nuevamente? [s/n]: " RESPUESTA_INSTALACION
		case "$RESPUESTA_INSTALACION" in
		[sS])
			echo "Reintentando instalación..."
			break
			;;
		[nN])
			echo "Instalación cancelada por el usuario."
			exit 1
			;;
		*)
			echo "Respuesta no válida. Por favor escribe 's' para sí o 'n' para no."
			;;
		esac
	done
done

#############################
# Configuración del sistema #
#############################

# Cambiamos el layout de teclado de la tty a español
echo "KEYMAP=es" | doas tee -a /etc/vconsole.conf

# Establecemos la versión de java por defecto
sudo /usr/bin/archlinux-java set java-21-openjdk

# Configurar el audio de baja latencia
audio-setup

# Instalar un servicio de systemd para suspender el equipo cuando la batería
# esta por debajo del 10%
sudo /usr/bin/install -o root -g root -m 0755 \
	"$HOME/.dotfiles/assets/system/services/auto-suspend/auto-suspend-loop" \
	/usr/local/bin/auto-suspend-loop

sudo /usr/bin/install -o root -g root -m 0644 \
	"$HOME/.dotfiles/assets/system/services/auto-suspend/systemd-service" \
	/etc/systemd/system/auto-suspend.service

# Permitir al usuario escanear redes Wi-Fi y cambiar ajustes de red sin
# introducir la contraseña
sudo /usr/bin/usermod -aG network "$USER"
sudo /usr/bin/cp -f \
	"$HOME/.dotfiles/assets/system/udev/50-org.freedesktop.NetworkManager.rules" \
	/etc/polkit-1/rules.d/

# Configuramos crond para borrar los módulos del kernel antiguos
cat <<-EOF | sudo /usr/bin/tee -a /etc/crontab >/dev/null
	@hourly root cleanup-old-modules
EOF

# Añadir entradas a /etc/environment
cat <<EOF | sudo /usr/bin/tee -a /etc/environment
CARGO_HOME="$HOME/.local/share/cargo"
GNUPGHOME="$HOME/.local/share/gnupg"
EOF

###########################
# Creación de directorios #
###########################

# Creamos los directorios básicos del usuario
for DIR in Documentos Música Imágenes Público Vídeos; do
	mkdir -p "$HOME/$DIR"
done
ln -s /tmp/ "$HOME/Descargas"
mkdir -p "$HOME/.config"

# Crear el directorio /.Trash con permisos adecuados
trash_dir

# Creamos un directorio para gnupg
mkdir -p "$HOME"/.local/share/gnupg/private-keys-v1.d
chmod 700 -R ~/.local/share/gnupg
mkdir -p "$HOME"/.local/share/cargo

# Creamos el directorio para los archivos .desktop locales
[ -d /usr/local/share/applications ] || sudo /usr/bin/mkdir -p /usr/local/share/applications

#####################################
# Configuración de las aplicaciones #
#####################################

# Añadimos el Xresources
XRES_FILE="$HOME/.config/Xresources"
cp "$HOME/.dotfiles/assets/configs/Xresources" "$XRES_FILE"

# Configuramos Tauon Music Box (Reproductor de música)
tauon-config

# Configuramos firefox
firefox-config

# Descargar los diccionarios para vim
vim_spell_download

# Instalar los archivos de configuración
"$HOME/.dotfiles/update.sh"

##############################
# Instalar software opcional #
##############################

[ "$CHOSEN_AUDIO_PROD" == "true" ] && opt_audio_prod
[ "$CHOSEN_LATEX" == "true" ] && opt_latex
[ "$CHOSEN_MUSIC" == "true" ] && opt_music
[ "$CHOSEN_VIRT" == "true" ] && opt_virt

##############
# Miscelánea #
##############

# Selecciona zsh como el shell del usuario
echo "ZDOTDIR=\$HOME/.config/zsh" | sudo /usr/bin/tee /etc/zsh/zshenv
sudo /usr/bin/chsh -s /bin/zsh "$USER"

# Activar WiFi y Bluetooth
sudo /usr/bin/rfkill unblock wifi
{ lspci | grep -qi bluetooth || lsusb | grep -qi bluetooth; } &&
	sudo /usr/bin/rfkill unblock bluetooth

# Añadimos al usuario a los grupos correspondientes
sudo /usr/bin/usermod -aG storage "$USER"
sudo /usr/bin/usermod -aG input "$USER"
sudo /usr/bin/usermod -aG users "$USER"
sudo /usr/bin/usermod -aG video "$USER"
sudo /usr/bin/usermod -aG optical "$USER"
sudo /usr/bin/usermod -aG uucp "$USER"

# Sincronizar las bases de datos de los paquetes
sudo /usr/bin/pacman -Fy

WINEPREFIX="$HOME/.config/wineprefixes" winetricks -q mfc42

# Borrar archivos innecesarios
rm "$HOME"/.bash* 2>/dev/null
rm "$HOME"/.wget-hsts 2>/dev/null

# Configuramos sudo de forma segura
sudo /usr/bin/install -o root -g root -m 440 \
	"$HOME/.dotfiles/assets/configs/sudoers" /etc/sudoers

# Ahora que el instalador ha terminado, cambiamos el repositorio para que
# siga los cambios
sh -c "
	cd $HOME/.dotfiles
	git fetch origin main
	git checkout main
	git pull
"

clear
toilet "Instalación terminada"
echo "La instalación ha terminado. Reinicia tu ordenador cuando estés listo"
