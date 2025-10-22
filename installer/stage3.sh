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

	amd)
		DRIVERS_VID+=(
			"lib32-mesa"
			"lib32-vulkan-radeon"
			"mesa"
			"vulkan-radeon"
			"xf86-video-amdgpu"
		)
		;;

	nvidia)
		DRIVERS_VID+=(
			"dkms"
			"lib32-nvidia-utils"
			"libva-mesa-driver"
			"libva-nvidia-driver"
			"nvidia-dkms"
			"nvidia-prime"
			"nvidia-utils"
			"opencl-nvidia"
		)
		;;

	intel)
		DRIVERS_VID+=(
			"lib32-libva-intel-driver"
			"lib32-vulkan-intel"
			"libva-intel-driver"
			"vulkan-intel"
			"xf86-video-intel"
		)
		;;

	vm)
		DRIVERS_VID+=(
			"lib32-vulkan-virtio"
			"vulkan-virtio"
			"xf86-input-vmmouse"
		)
		;;
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

# Configurar Xresources
xresources_make() {
	mkdir -p "$HOME/.config"
	XRES_FILE="$HOME/.config/Xresources"
	cp "$HOME/.dotfiles/assets/configs/Xresources" "$XRES_FILE"
	# Añadimos nuestro DPI a el arcivo Xresources
	echo "Xft.dpi:$FINAL_DPI" | tee -a "$XRES_FILE"
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

##########################
# Aquí empieza el script #
##########################

# Instalamos yay (https://aur.archlinux.org/packages/yay)
yay-install

# Reemplamos sudo por doas
sudo sudo2doas

# Crear directorios
for DIR in Documentos Música Imágenes Público Vídeos; do
	mkdir -p "$HOME/$DIR"
done
ln -s /tmp/ "$HOME/Descargas"

# Escogemos que drivers de vídeo instalar
driver_add

# Calcular el DPI de nuestra pantalla y configurar Xresources
xresources_make

# Antes de instalar los paquetes, configurar makepkg para
# usar todos los núcleos durante la compilación
sudo /usr/bin/sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

# Instalamos todos los paquetes a la vez
while true; do
	# En cada iteración se vuelven a leer los archivos con los paquetes a instalar
	# De este modo en caso de error podemos intervenir más facilmente
	arr_packages

	yayinstall "${PACKAGES[@]}" && break

	echo
	echo "La instalación de los paquetes falló. Por favor revisa tu conexión."
	echo

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

# Configuramos Tauon Music Box (Nuestro reproductor de música)
tauon-config
# Configuramos firefox
firefox-config

# Establecemos la versión de java por defecto
sudo /usr/bin/archlinux-java set java-21-openjdk

# Descargar los diccionarios para vim
vim_spell_download

# Instalar los archivos de configuración e instalar plugins de zsh
dotfiles-install

# Crear el directorio /.Trash con permisos adecuados
trash_dir

# Borrar los módulos del kernel antiguos
cat <<-EOF | sudo /usr/bin/tee -a /etc/crontab >/dev/null
	@hourly root cleanup-old-modules
EOF

# Activar WiFi y Bluetooth
sudo /usr/bin/rfkill unblock wifi
{ lspci | grep -i bluetooth || lsusb | grep -i bluetooth; } >/dev/null &&
	sudo /usr/bin/rfkill unblock bluetooth

# Añadimos al usuario a los grupos correspondientes
sudo /usr/bin/usermod -aG storage,input,users,video,optical,uucp "$USER"

# Configurar el software opcional
[ "$CHOSEN_AUDIO_PROD" == "true" ] && opt_audio_prod
[ "$CHOSEN_LATEX" == "true" ] && opt_latex
[ "$CHOSEN_MUSIC" == "true" ] && opt_music
[ "$CHOSEN_VIRT" == "true" ] && opt_virt

# Configurar el audio de baja latencia
audio-setup

# Sincronizar las bases de datos de los paquetes
sudo /usr/bin/pacman -Fy

# Creamos un directorio para gnupg
mkdir -p "$HOME"/.local/share/gnupg/private-keys-v1.d
chmod 700 -R ~/.local/share/gnupg
mkdir -p "$HOME"/.local/share/cargo

# Añadir entradas a /etc/environment
cat <<EOF | sudo /usr/bin/tee -a /etc/environment
CARGO_HOME="$HOME/.local/share/cargo"
GNUPGHOME="$HOME/.local/share/gnupg"
EOF

WINEPREFIX="$HOME/.config/wineprefixes" winetricks -q mfc42

# Borrar archivos innecesarios
rm "$HOME"/.bash* 2>/dev/null
rm "$HOME"/.wget-hsts 2>/dev/null

# Cambiamos el layout de teclado de la tty a español
echo "KEYMAP=es" | doas tee -a /etc/vconsole.conf

toilet "Instalación terminada"
echo "La instalación ha terminado. Reinicia tu ordenador cuando estés listo"
