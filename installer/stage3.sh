#!/bin/bash
# shellcheck disable=SC2068,SC2154,SC1091

# Auto-instalador para Arch Linux (Parte 3)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# Hacemos source porque el shell del usuario normal se ha iniciado desde
# stage2.sh sin tener todavia el perfil del shell en ~/.profile
source "$HOME/.dotfiles/assets/shell/profile"
source "$HOME/.dotfiles/assets/shell/shell-utils"

# Importamos todos los componentes en los que se separa el script
PATH="$PATH:$(find ~/.dotfiles/installer/modules -type d | paste -sd ':' -)"

# Instalar paquetes con yay
yayinstall() {
	yay -Sy --noconfirm --needed "$@"
}

PACKAGES=()
DRIVERS_VID=()

# shellcheck disable=SC2155,SC2207
graphic_driver_add() {
	local PACKAGE_LIST="$REPO_DIR/assets/packages/video_drivers.json"
	local GRAPHIC_DRIVER
	local DRIVERS=$(lsmod | grep -oE "nvidia|amdgpu|i915|virtio_gpu" | sort -u)

	for driver in $DRIVERS; do
		case "$driver" in
		i915) GRAPHIC_DRIVER=intel ;;
		virtio_gpu) GRAPHIC_DRIVER=vm ;;
		nvidia) GRAPHIC_DRIVER=nvidia ;;
		amdgpu) GRAPHIC_DRIVER=amd ;;
		*) continue ;;
		esac
		DRIVERS_VID+=($(jq -r ".${GRAPHIC_DRIVER}[]" "$PACKAGE_LIST"))
	done

	if [ "${#DRIVERS_VID[@]}" -eq 0 ]; then
		DRIVERS_VID+=(mesa)
	else
		# Eliminar duplicados
		DRIVERS_VID=($(printf "%s\n" "${DRIVERS_VID[@]}" | sort -u))
	fi
}

arr_packages() {
	mapfile -t TMP_PACKAGES < <(
		find "$REPO_DIR/assets/packages" -name '*.hjson' \
			-exec sh -c 'hjson -j "$1" | jq -r ".[] | .[]"' _ {} \;
	)
	PACKAGES=("${TMP_PACKAGES[@]}" "${DRIVERS_VID[@]}")
}

vim_spell_download() {
	mkdir -p "$HOME/.local/share/nvim/site/spell/"
	wget "https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.spl" \
		-q -O "$HOME/.local/share/nvim/site/spell/es.utf-8.spl"
	wget "https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.sug" \
		-q -O "$HOME/.local/share/nvim/site/spell/es.utf-8.sug"
}

create_trash_dir() {
	sudo /usr/bin/mkdir --parent /.Trash
	sudo /usr/bin/chmod a+rw /.Trash
	sudo /usr/bin/chmod +t /.Trash
}

#-------------------------------------------------------------------------------

# Antes de instalar los paquetes, configuramos makepkg para
# usar todos los núcleos durante la compilación
sudo /usr/bin/sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

mkdir -p "$HOME"/.local/share/gnupg/private-keys-v1.d
chmod 700 -R ~/.local/share/gnupg
mkdir -p "$HOME"/.local/share/cargo

# Instalamos yay (https://aur.archlinux.org/packages/yay)
yay-install

# Instalamos todos los paquetes a la vez
while true; do
	# Añadimos los drivers de vídeo a la lista de paquetes. La lista de paquetes
	# se obtiene del siguiente archivo en cada iteración para facilitar el depurado:
	#     ~/.dotfiles/assets/video_driver_packages.hjson
	graphic_driver_add
	# Añadimos los demás paquetes a instalar. La lista de paquetes se obtiene
	# de los siguientes archivos en cada iteración para facilitar el depurado:
	#     ~/.dotfiles/assets/packages/*.hjson
	arr_packages

	yayinstall "${PACKAGES[@]}" && break

	echo "La instalación de los paquetes falló. Por favor revisa tu conexión."

	# Preguntamos al usuario como continuar si hubo un fallo
	while true; do
		read -rp "¿Deseas intentar la instalación nuevamente? [s/n]: " RESPUESTA_INSTALACION
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

# Configuración del sistema
#-------------------------------------------------------------------------------

echo "KEYMAP=es" | sudo /usr/bin/tee -a /etc/vconsole.conf

sudo /usr/bin/archlinux-java set java-21-openjdk

audio-setup
libvirt-setup

# Instalar un servicio de systemd para suspender el equipo cuando la batería
# esta por debajo del 10%
sudo /usr/bin/install -o root -g root -m 0755 \
	"$REPO_DIR/assets/system/services/auto-suspend/auto-suspend-loop" \
	/usr/local/bin/auto-suspend-loop
sudo /usr/bin/install -o root -g root -m 0644 \
	"$REPO_DIR/assets/system/services/auto-suspend/systemd-service" \
	/etc/systemd/system/auto-suspend.service

# Permitir al usuario escanear redes Wi-Fi y cambiar ajustes de red sin
# introducir la contraseña
sudo /usr/bin/usermod -aG network "$USER"
sudo /usr/bin/cp -f \
	"$REPO_DIR/assets/system/udev/50-org.freedesktop.NetworkManager.rules" \
	/etc/polkit-1/rules.d/

# Configuramos crond para borrar los módulos del kernel antiguos
cat <<-EOF | sudo /usr/bin/tee -a /etc/crontab >/dev/null
	@hourly root cleanup-old-modules
EOF

cat <<EOF | sudo /usr/bin/tee -a /etc/environment
CARGO_HOME="$HOME/.local/share/cargo"
GNUPGHOME="$HOME/.local/share/gnupg"
EOF

#-------------------------------------------------------------------------------

ln -s /tmp/ "$HOME/Descargas"
mkdir -p "$HOME/.config"

# Creamos los directorios básicos del usuario
for DIR in Documentos Música Imágenes Público Vídeos; do
	mkdir -p "$HOME/$DIR"
done

create_trash_dir

[ -d /usr/local/share/applications ] ||
	sudo /usr/bin/mkdir -p /usr/local/share/applications

#-------------------------------------------------------------------------------

# Añadimos el Xresources
XRES_FILE="$HOME/.config/Xresources"
cp "$REPO_DIR/assets/configs/Xresources" "$XRES_FILE"

vim_spell_download

"$REPO_DIR/update.sh"

#-------------------------------------------------------------------------------

LRCPUT_TARGET="$HOME/.local/bin/lrcput"

ensure_dir "$HOME/.local/bin" >/dev/null
download \
	"https://raw.githubusercontent.com/JustOptimize/lrcput/refs/heads/main/lrcput.py" \
	"$LRCPUT_TARGET"

if [ -f "$LRCPUT_TARGET" ]; then
	sed -i '1i #!/usr/bin/python' "$LRCPUT_TARGET"
	chmod +x "$LRCPUT_TARGET"
fi

#-------------------------------------------------------------------------------

echo "ZDOTDIR=\$HOME/.config/zsh" | sudo /usr/bin/tee /etc/zsh/zshenv
sudo /usr/bin/chsh -s /bin/zsh "$USER"

# Activar WiFi y Bluetooth
sudo /usr/bin/rfkill unblock wifi
{ lspci | grep -qi bluetooth || lsusb | grep -qi bluetooth; } &&
	sudo /usr/bin/rfkill unblock bluetooth

GROUPS=(
	"storage"
	"input"
	"users"
	"video"
	"optical"
	"uucp"
)
for group in "${GROUPS[@]}"; do
	sudo /usr/bin/usermod -aG "$group" "$USER"
done

sudo /usr/bin/pacman -Fy

rm "$HOME"/.bash* 2>/dev/null
rm "$HOME"/.wget-hsts 2>/dev/null

# Actualizamos al configuracion de GRUB
# (para iniciar con el núcleo instalado en este script)
sudo /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg

# Instalar el hook de pacman para firefox (arkenfox)
sudo /usr/bin/mkdir -p /usr/local/lib /etc/pacman.d/hooks
sudo /usr/bin/cp -f "$REPO_DIR/bin/arkenfox-auto-update" \
	/usr/local/lib/arkenfox-auto-update
sudo /usr/bin/cp -f "$REPO_DIR/assets/system/arkenfox.hook" \
	/etc/pacman.d/hooks/arkenfox.hook
sudo /usr/bin/chmod 755 /usr/local/lib/arkenfox-auto-update

# Configuramos sudo de forma segura
sudo /usr/bin/install -o root -g root -m 440 \
	"$REPO_DIR/assets/configs/sudoers" /etc/sudoers

# Hacemos que el repositorio local siga los cambios en
# caso de que se usase el instalador en un tag concreto
sh -c "
	cd $REPO_DIR
	git fetch origin main
	git checkout main
	git pull
"

touch "$HOME/.system_not_initialized"

clear
toilet "Instalación terminada"
echo "La instalación ha terminado. Reinicia tu ordenador cuando estés listx"
