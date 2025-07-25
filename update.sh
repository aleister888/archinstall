#!/bin/bash
# shellcheck disable=SC2086

# Instalador de ajustes para Arch Linux
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# Variables
export DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
export CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
export REPO_DIR="$HOME/.dotfiles"
export ASSETDIR="$REPO_DIR/assets/configs"

trap 'fc-cache -f' EXIT

# Guardamos el hash del script para comprobar mas adelante si este ha cambiado
OG_HASH=$(sha256sum "$0" | awk '{print $1}')

# Si tenemos conexión a Internet y el repo. clonado, lo actualizamos
if [ -d "$REPO_DIR/.git" ] && timeout -k 1s 3s ping gnu.org -c 1 >/dev/null 2>&1; then
	sh -c "cd $REPO_DIR && git pull" >/dev/null
fi

# Guardamos el hash tras hacer pull
NEW_HASH=$(sha256sum "$0" | awk '{print $1}')

# Si el script se actualizó, usar la versión más reciente
if [ "$OG_HASH" != "$NEW_HASH" ]; then
	exec "$0" "$@"
fi

###############################
# Instalar paquetes faltantes #
###############################

# Construimos la lista de paquetes dependiendo de la distro
mapfile -t PACKAGE_LIST < <(
	find "$HOME/.dotfiles/assets/packages" -name '*.json' \
		-exec jq -r '.[] | .[]' {} +
)

# Extraemos solo el nombre del paquete (sin prefijo repo/)
REPO_PKGS=$(printf "%s\n" "${PACKAGE_LIST[@]}" | cut -d/ -f2)

# Paquetes ya instalados
INSTALLED_PKGS=$(yay -Qq)

# Filtramos los paquetes que aún no están instalados
PKGS_TO_INSTALL=$(comm -23 <(printf "%s\n" "$REPO_PKGS" | sort) <(printf "%s\n" "$INSTALLED_PKGS" | sort))

# Si hay paquetes pendientes y tenemos internet, los instalamos
if [ -n "$PKGS_TO_INSTALL" ] && timeout -k 1s 3s ping -q -c 1 gnu.org &>/dev/null; then
	yay -Sy --noconfirm --needed --asexplicit $PKGS_TO_INSTALL
fi

# Crear los directorios necesarios
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
[ -d "$HOME/.cache" ] || mkdir -p "$HOME/.cache"
[ -d "$CONF_DIR" ] || mkdir -p "$CONF_DIR"
[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"

###########
# Módulos #
###########

# Instalar/actualizar archivos de configuración
"$HOME"/.dotfiles/updater/install-conf &
# Crear enlaces simbólicos en /usr/local/bin para ciertos scripts
"$HOME"/.dotfiles/updater/install-bin &
# Activar los servicios necesarios
"$HOME"/.dotfiles/updater/conf-services &
# Añade integración con dbus para lf
"$HOME"/.dotfiles/updater/lf-dbus &
wait

############################
# Aplicaciones por defecto #
############################

# Establecer las aplicaciones por defecto para cada mimetype
"$HOME"/.dotfiles/updater/xdg-config &

#######################################
# Archivos de configuración y scripts #
#######################################

# Instalar archivos de configuración y scripts
sh -c "cd $REPO_DIR && stow --adopt --target=${HOME}/.local/bin/ bin/" >/dev/null &
sh -c "cd $REPO_DIR && stow --adopt --target=${HOME}/.config/ .config/" >/dev/null &

ln -sf "$REPO_DIR/assets/configs/.profile" "$HOME/.profile"
ln -sf "$REPO_DIR/assets/configs/.profile" "$CONF_DIR/zsh/.zprofile"

# Borrar enlaces rotos
find "$HOME/.local/bin" -type l ! -exec test -e {} \; -delete &
find "$CONF_DIR" -type l ! -exec test -e {} \; -delete &

mkdir -p ~/.config/xdg-desktop-portal/
cat <<-EOF >~/.config/xdg-desktop-portal/portals.conf
	[preferred]
	default=hyprland
EOF

#########################
# Configurar apariencia #
#########################

# Configurar el tema del cursor
if [ ! -e "$REPO_DIR/assets/configs/index.theme" ]; then
	mkdir -p "$DATA_DIR/icons/default"
	cp "$REPO_DIR/assets/configs/index.theme" \
		"$DATA_DIR/icons/default/index.theme"
fi &

#######################
# Configurar GTK y QT #
#######################

rm -rf ~/.config/gtk-4.0/* ~/.config/gtk-3.0/settings.ini
mkdir -p "$HOME/.local/share/nwg-look" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
cp "$ASSETDIR/gtk/gsettings" "$HOME/.local/share/nwg-look/gsettings"
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
nwg-look -a
nwg-look -x

if [ ! -f "$CONF_DIR/gtk-3.0/bookmarks" ]; then
	# Definimos nuestros directorios anclados
	cat <<-EOF >"$CONF_DIR/gtk-3.0/bookmarks"
		file://$HOME
		file://$HOME/Descargas
		file://$HOME/Documentos
		file://$HOME/Imágenes
		file://$HOME/Vídeos
		file://$HOME/Música
	EOF
fi

# Instalamos el tema de GTK4
if [ ! -d /usr/share/themes/Gruvbox-Dark ]; then
	REPO_URL="https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme"
	# Descargamos el tema
	wget "$REPO_URL/archive/refs/heads/master.zip" -q -O \
		/tmp/Gruvbox-Dark.zip
	unzip /tmp/Gruvbox-Dark.zip -d /tmp/
	# Lo instalamos
	sudo bash /tmp/Gruvbox-GTK-Theme-master/themes/install.sh
fi &

# Configuramos QT
if [ ! -e "$CONF_DIR/qt5ct/qt5ct.conf" ] ||
	[ ! -e "$CONF_DIR/qt6ct/qt6ct.conf" ]; then
	mkdir -p "$CONF_DIR/qt5ct" "$CONF_DIR/qt6ct"
	cat <<-EOF | tee "$CONF_DIR/qt5ct/qt5ct.conf" "$CONF_DIR/qt6ct/qt6ct.conf" >/dev/null
		[Appearance]
		color_scheme_path=$REPO_DIR/assets/qt-colors/Gruvbox.conf
		custom_palette=true
		icon_theme=Papirus-Dark
		style=Fusion

		[Fonts]
		fixed="Iosevka Fixed SS05,12,0,0,0,0,0,0,0,0,Bold"
		general="Iosevka Fixed SS05 Semibold,12,0,0,0,0,0,0,0,0,Regular"
	EOF
fi

#####################
# Archivos .desktop #
#####################

[ -d /usr/local/share/applications ] ||
	sudo mkdir -p /usr/local/share/applications

# Ocultar archivos .desktop innecesarios
DESKTOPENT=(
	"Surge-XT"
	"Surge-XT-FX"
	"assistant"
	"avahi-discover"
	"bssh"
	"bvnc"
	"cmake-gui"
	"designer"
	"echomixer"
	"envy24control"
	"fluid"
	"hdajackretask"
	"hdspconf"
	"hdspmixer"
	"hp-uiscan"
	"htop"
	"hwmixvolume"
	"jconsole-java-openjdk"
	"jconsole-java17-openjdk"
	"jconsole-java21-openjdk"
	"jshell-java-openjdk"
	"jshell-java17-openjdk"
	"jshell-java21-openjdk"
	"lf"
	"linguist"
	"lstopo"
	"nvim"
	"picom"
	"qdbusviewer"
	"qv4l2"
	"qvidcap"
	"redshift"
	"redshift-gtk"
	"xdvi"
)

# Ocultamos estas entradas .desktop
for ENTRY in "${DESKTOPENT[@]}"; do
	if [ -e "/usr/share/applications/$ENTRY.desktop" ]; then
		sudo cp -f "/usr/share/applications/$ENTRY.desktop" \
			"/usr/local/share/applications/$ENTRY.desktop"
		echo 'NoDisplay=true' | sudo tee -a \
			"/usr/local/share/applications/$ENTRY.desktop"
	fi
done >/dev/null &

# Copiamos archivos .desktop
cp -f "$HOME/.dotfiles/assets/desktop/rdp.desktop" \
	"${XDG_DATA_HOME:-$HOME/.local/share}/applications/rdp.desktop"

####################################
# Actualizar iconos y colores (lf) #
####################################

LF_URL="https://raw.githubusercontent.com/gokcehan/lf/master/etc"
curl $LF_URL/colors.example -o ~/.config/lf/colors 2>/dev/null &
curl $LF_URL/icons.example -o ~/.config/lf/icons 2>/dev/null &

#############################
# Añadir diccionarios a vim #
#############################

[ ! -d "$DATA_DIR/nvim/site/spell" ] &&
	mkdir -p "$DATA_DIR/nvim/site/spell"

[ ! -f "$DATA_DIR/nvim/site/spell/es.utf-8.spl" ] &&
	wget 'https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.spl' -q -O \
		"$DATA_DIR/nvim/site/spell/es.utf-8.spl" &

[ ! -f "$DATA_DIR/nvim/site/spell/es.utf-8.sug" ] &&
	wget 'https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.sug' -q -O \
		"$DATA_DIR/nvim/site/spell/es.utf-8.sug" &
