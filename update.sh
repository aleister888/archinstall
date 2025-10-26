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

DEBUG=false

# Comprobamos si el script se ejecutó en modo debug
while getopts "d" opt; do
	case $opt in
	d) DEBUG=true ;;
	*) ;;
	esac
done

# Si está en modo debug, activamos xtrace
# Además, los scripts de "$HOME"/.dotfiles/updater no se ejecutarán
# en modo silencioso
if [ "$DEBUG" = true ]; then
	set -x
fi

trap 'fc-cache -f' EXIT

################################################
# Actualizar repo, informar cambios en sudoers #
################################################

# Guardamos el hash del script para comprobar mas adelante si este ha cambiado
OG_HASH=$(sha256sum "$0" | awk '{print $1}')

# Guardamos el hash del archivo sudoers para comprobar si este ha cambiado
SUDOERS_HASH=$(sha256sum "$ASSETDIR/sudoers" | awk '{print $1}')

# Comprobamos si tenemos conexión a Internet
CONNECTED=false
{
	timeout -k 1s 3s ping -c 1 8.8.8.8 ||
		timeout -k 1s 3s curl -s --head --request GET "https://dns.google/"
} >/dev/null 2>&1 && CONNECTED=true

notify_sudoers_change() {
	echo "El archivo sudoers tiene cambios desde la última actualización"
	echo
	echo "Puedes actualizarlo con:"
	echo -e "\tsudo install -o root -g root -m 440 \\"
	echo -e "\t\t\"$HOME/.dotfiles/assets/configs/sudoers\" /etc/sudoers"
}

# Si tenemos conexión a Internet y el repo. clonado, lo actualizamos
if [ -d "$REPO_DIR/.git" ] && [ "$CONNECTED" == "true" ]; then
	sh -c "cd $REPO_DIR && git pull" >/dev/null
	# Si al actualizar el repo el archivo sudoers cambió, se lo haremos
	# saber al usuario al terminar la ejecución
	if [[ "$SUDOERS_HASH" != $(sha256sum "$ASSETDIR/sudoers" | awk '{print $1}') ]]; then
		trap notify_sudoers_change EXIT
	fi

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
	find "$HOME/.dotfiles/assets/packages" -name '*.hjson' \
		-exec sh -c 'hjson -j "$1" | jq -r ".[] | .[]" ' _ {} \;
)

# Extraemos solo el nombre del paquete (sin prefijo repo/)
REPO_PKGS=$(printf "%s\n" "${PACKAGE_LIST[@]}" | cut -d/ -f2)

# Paquetes ya instalados
INSTALLED_PKGS=$(yay -Qq)

# Filtramos los paquetes que aún no están instalados
PKGS_TO_INSTALL=$(comm -23 <(printf "%s\n" "$REPO_PKGS" | sort -u) <(printf "%s\n" "$INSTALLED_PKGS" | sort))

# Si hay paquetes pendientes y tenemos internet, los instalamos
if [ -n "$PKGS_TO_INSTALL" ] && [ "$CONNECTED" == "true" ]; then
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

# Si DEBUG=true hacemos visible la salida
if [ "$DEBUG" = true ]; then
	# Instalar/actualizar archivos de configuración
	"$HOME"/.dotfiles/updater/install-conf -d &
	# Crear enlaces simbólicos en /usr/local/bin para ciertos scripts
	"$HOME"/.dotfiles/updater/install-bin -d &
	# Activar los servicios necesarios
	"$HOME"/.dotfiles/updater/conf-services -d &
	# Añade integración con dbus para lf
	"$HOME"/.dotfiles/updater/lf-dbus &
else
	# Instalar/actualizar archivos de configuración
	"$HOME"/.dotfiles/updater/install-conf >/dev/null 2>&1 &
	# Crear enlaces simbólicos en /usr/local/bin para ciertos scripts
	"$HOME"/.dotfiles/updater/install-bin >/dev/null 2>&1 &
	# Activar los servicios necesarios
	"$HOME"/.dotfiles/updater/conf-services >/dev/null 2>&1 &
	# Añade integración con dbus para lf
	"$HOME"/.dotfiles/updater/lf-dbus >/dev/null 2>&1 &
fi
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

# Enlazamos el archivo .profile
ln -sf "$REPO_DIR/assets/configs/.profile" "$HOME/.profile"
ln -sf "$REPO_DIR/assets/configs/.profile" "$HOME/.bash_profile"
ln -sf "$REPO_DIR/assets/configs/.profile" "$CONF_DIR/zsh/.zprofile"

# Borrar enlaces rotos
find "$HOME/.local/bin" -type l ! -exec test -e {} \; -delete &
find "$CONF_DIR" -type l ! -exec test -e {} \; -delete &

# Configuramos el portal de XDG
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

# Borramos las configuraciones de GTK anteriores
rm -rf ~/.config/gtk-4.0/* ~/.config/gtk-3.0/settings.ini

# Instalamos nuestra configuración de nwg-look
mkdir -p "$HOME/.local/share/nwg-look" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
install "$ASSETDIR/gtk/gsettings" "$HOME/.local/share/nwg-look/gsettings"

# Especificamos que queremos usar la variante oscura de nuestro tema
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

# Creamos la configuración de GTK usando nwg-look
nwg-look -a 2>/dev/null
nwg-look -x 2>/dev/null

# Añadimos a marcadores las carpetas básicas (Si no hay archivo de marcadores)
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

# Instalamos el tema de GTK
if [ ! -d /usr/local/share/themes/Gruvbox-Dark ]; then
	# https://www.pling.com/p/1681313/
	unzip "$ASSETDIR/gtk/Gruvbox-Dark-BL-LB.zip" -d /tmp/
	# Borramos cualquier otra versión de Gruvbox
	sudo /usr/bin/mkdir -p /usr/local/share/themes
	sudo /usr/bin/rm -rf /usr/local/share/themes/Gruvbox-*
	sudo /usr/bin/cp -rf /tmp/Gruvbox-Dark/ /usr/local/share/themes/
	sudo /usr/bin/cp -rf /tmp/Gruvbox-Dark-hdpi /usr/local/share/themes/
	sudo /usr/bin/cp -rf /tmp/Gruvbox-Dark-xhdpi /usr/local/share/themes/
fi &

# Configuramos QT
mkdir -p "$CONF_DIR/qt5ct" "$CONF_DIR/qt6ct"
cat <<-EOF | tee "$CONF_DIR/qt5ct/qt5ct.conf" "$CONF_DIR/qt6ct/qt6ct.conf" >/dev/null
	[Appearance]
	color_scheme_path=$REPO_DIR/assets/qt-colors/Gruvbox.conf
	custom_palette=true
	icon_theme=Papirus-Dark
	style=Fusion

	[Fonts]
	fixed="Fira Sans Condensed Mono,12,0,0,0,0,0,0,0,0,Bold"
	general="Fira Sans Condensed,12,0,0,0,0,0,0,0,0,Bold"
EOF

#####################
# Archivos .desktop #
#####################

# Ocultar archivos .desktop innecesarios
DESKTOPENT=(
	"Surge-XT"
	"Surge-XT-FX"
	"assistant"
	"avahi-discover"
	"blueman-manager"
	"bssh"
	"bvnc"
	"cmake-gui"
	"designer"
	"echomixer"
	"electron37"
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
	"nwg-look"
	"picom"
	"qdbusviewer"
	"qv4l2"
	"qvidcap"
	"redshift"
	"redshift-gtk"
	"uuctl"
	"winetricks"
	"xdvi"
	"xgps"
	"xgpsspeed"
	"yad-settings"
)

# Ocultamos estas entradas .desktop
for ENTRY in "${DESKTOPENT[@]}"; do
	if [ -e "/usr/share/applications/$ENTRY.desktop" ]; then
		sudo /usr/bin/cp -f "/usr/share/applications/$ENTRY.desktop" \
			"/usr/local/share/applications/$ENTRY.desktop"
		echo 'NoDisplay=true' | sudo /usr/bin/tee -a \
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
