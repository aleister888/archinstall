#!/bin/bash
# shellcheck disable=SC2086,SC2155,SC1094,SC1091

# Instalador de ajustes para Arch Linux
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

source "$HOME/.dotfiles/assets/shell/profile"
source "$HOME/.dotfiles/assets/shell/shell-utils"

export DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
export CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
export ASSETDIR="$REPO_DIR/assets/configs"

export TMP_DIR="$(get_tmp updater)"
export LOG_DIR="$(init_log updater)"

[ -z "$DEBUG" ] && DEBUG=false

while getopts "d" opt; do
	case $opt in
	d) DEBUG=true ;;
	*) ;;
	esac
done

export DEBUG

#-------------------------------------------------------------------------------

notify_sudoers_change() {
	cat <<-'EOF'
		El archivo sudoers tiene cambios desde la última actualización

		Puedes actualizarlo con:
			sudo install -o root -g root -m 440 \
				"$HOME/.dotfiles/assets/configs/sudoers" /etc/sudoers
	EOF
	log "sudoers file outdated"
}

mapfile -t OLD_PACKAGE_LIST < <(
	find "$HOME/.dotfiles/assets/packages" -name '*.hjson' \
		-exec sh -c 'hjson -j "$1" | jq -r ".[] | .[]" ' _ {} \;
)

OG_HASH=$(sha256sum "$0" | awk '{print $1}')

if check_connection; then
	CONNECTED=true
else
	CONNECTED=false
	log "sin conexión" WARN
fi

if [ -d "$REPO_DIR/.git" ] && [ "$CONNECTED" == "true" ]; then
	OG_SUDOERS_HASH=$(sha256sum "$ASSETDIR/sudoers" | awk '{print $1}')
	git -C "$REPO_DIR" pull >/dev/null 2>&1 || log "couldn't pull repo"
	if [[ "$OG_SUDOERS_HASH" != $(sha256sum "$ASSETDIR/sudoers" | awk '{print $1}') ]]; then
		notify_sudoers_change
	fi
fi

mapfile -t PACKAGE_LIST < <(
	find "$HOME/.dotfiles/assets/packages" -name '*.hjson' \
		-exec sh -c 'hjson -j "$1" | jq -r ".[] | .[]" ' _ {} \;
)

# Detectar paquetes eliminados
mapfile -t REMOVED_PACKAGES < <(
	printf "%s\n" "${OLD_PACKAGE_LIST[@]}" |
		grep -Fxv -f <(printf "%s\n" "${PACKAGE_LIST[@]:-}") || true
)

if ((${#REMOVED_PACKAGES[@]})); then
	REMOVED_FILE="$LOG_DIR/uneeded_packages_$(date '+%Y-%m-%d_%H-%M-%S').txt"
	printf '%s\n' "${REMOVED_PACKAGES[@]}" | tee "$REMOVED_FILE"
	log "${#REMOVED_PACKAGES[@]} paquetes huérfanos detectados: $REMOVED_FILE"
fi

# Guardamos el hash tras hacer pull
NEW_HASH=$(sha256sum "$0" | awk '{print $1}')

# Si el script se actualizó, usar la versión más reciente
if [ "$OG_HASH" != "$NEW_HASH" ]; then
	exec "$0" "$@"
fi

REPO_PKGS=$(printf "%s\n" "${PACKAGE_LIST[@]}" | cut -d/ -f2) # Quitamos "repo/"
INSTALLED_PKGS=$(yay -Qq)                                     # Paquetes
INSTALLED_PKGS+=$(pacman -Qg | awk '{print $1}' | sort -u)    # Grupos

PKGS_TO_INSTALL=$(comm -23 <(printf "%s\n" "$REPO_PKGS" | sort -u) \
	<(printf "%s\n" "$INSTALLED_PKGS" | sort))

if [ -n "$PKGS_TO_INSTALL" ] && [ "$CONNECTED" == "true" ]; then
	yay -Sy --noconfirm --needed --asexplicit $PKGS_TO_INSTALL
fi

# shellcheck disable=SC2046
# pacman -D falla si todos los paquetes de la lista ya estában marcados
sudo /usr/bin/pacman -D --asexplicit $(xargs <<<$REPO_PKGS) >/dev/null 2>&1 || true

REPO_PKGS=$(printf "%s\n" "${PACKAGE_LIST[@]}" | cut -d/ -f2)

# Crear los directorios necesarios
ensure_dir "$HOME/.local/bin" >/dev/null
ensure_dir "$HOME/.cache" >/dev/null
ensure_dir "$CONF_DIR" >/dev/null
ensure_dir "$DATA_DIR" >/dev/null

#-------------------------------------------------------------------------------

ensure_dir "$DATA_DIR/nvim/site/spell" >/dev/null

[ ! -f "$DATA_DIR/nvim/site/spell/es.utf-8.spl" ] &&
	wget 'https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.spl' -q -O \
		"$DATA_DIR/nvim/site/spell/es.utf-8.spl" &

[ ! -f "$DATA_DIR/nvim/site/spell/es.utf-8.sug" ] &&
	wget 'https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.sug' -q -O \
		"$DATA_DIR/nvim/site/spell/es.utf-8.sug" &

#-------------------------------------------------------------------------------

(cd $REPO_DIR && stow --adopt --target=${HOME}/.local/bin/ bin/) >/dev/null &
(cd $REPO_DIR && stow --adopt --target=${HOME}/.config/ .config/) >/dev/null &

mkdir -p "$CONF_DIR/zsh"
ln -sf "$REPO_DIR/assets/shell/profile" "$CONF_DIR/zsh/.zprofile"
ln -sf "$REPO_DIR/assets/shell/profile" "$HOME/.profile"
ln -sf "$REPO_DIR/assets/shell/profile" "$HOME/.bash_profile"

# Borrar enlaces rotos
find "$HOME/.local/bin" -type l ! -exec test -e {} \; -delete &
find "$CONF_DIR" -type l ! -exec test -e {} \; -delete &

mkdir -p ~/.config/xdg-desktop-portal/
cat <<-EOF >~/.config/xdg-desktop-portal/portals.conf
	[preferred]
	default=hyprland
EOF

#-------------------------------------------------------------------------------

if [ "$DEBUG" = true ]; then
	"$HOME"/.dotfiles/updater/conf-services
	"$HOME"/.dotfiles/updater/install-bin &
	"$HOME"/.dotfiles/updater/install-conf
	"$HOME"/.dotfiles/updater/lf-dbus &
else
	"$HOME"/.dotfiles/updater/conf-services 2>/dev/null
	"$HOME"/.dotfiles/updater/install-bin 2>/dev/null &
	"$HOME"/.dotfiles/updater/install-conf 2>/dev/null
	"$HOME"/.dotfiles/updater/lf-dbus 2>/dev/null &
fi
wait

fc-cache -f &

"$HOME"/.dotfiles/updater/xdg-default-apps &

is_chroot || "$HOME"/.dotfiles/updater/nix-conf &

#-------------------------------------------------------------------------------

IGNORE_GENERAL="$REPO_DIR/assets/desktop-ignore/general.txt"
IGNORE_LSP="$REPO_DIR/assets/desktop-ignore/lsp.txt"

mapfile -t GENERAL_DESKTOP <"$IGNORE_GENERAL"
mapfile -t LSP_DESKTOP <"$IGNORE_LSP"

ALL_IGNORE=("${LSP_DESKTOP[@]}" "${GENERAL_DESKTOP[@]}")

# TODO: add support for nix pkgs .desktop files

# Ocultamos estas entradas .desktop
for ENTRY in "${ALL_IGNORE[@]}"; do
	OG_DESKTOP="/usr/share/applications/$ENTRY.desktop"
	MOD_DESKTOP="/usr/local/share/applications/$ENTRY.desktop"
	if [ -e "$OG_DESKTOP" ]; then
		(
			sudo /usr/bin/cp -f "$OG_DESKTOP" "$MOD_DESKTOP"
			if [ -s "$MOD_DESKTOP" ] && [ -n "$(tail -c1 "$MOD_DESKTOP")" ]; then
				# Último carácter no es salto de línea
				printf '\nNoDisplay=true\n' | sudo tee -a "$MOD_DESKTOP" >/dev/null
			else
				printf 'NoDisplay=true\n' | sudo tee -a "$MOD_DESKTOP" >/dev/null
			fi
		) &
	else
		log "desktop file not found: $ENTRY" WARN
	fi
done &

ensure_dir "${XDG_DATA_HOME:-$HOME/.local/share}/applications" >/dev/null

# Copiamos archivos .desktop
cp -f "$HOME/.dotfiles/assets/desktop/rdp.desktop" \
	"${XDG_DATA_HOME:-$HOME/.local/share}/applications/rdp.desktop"

#-------------------------------------------------------------------------------

if [ ! -e "$REPO_DIR/assets/configs/index.theme" ]; then
	mkdir -p "$DATA_DIR/icons/default"
	cp "$REPO_DIR/assets/configs/index.theme" \
		"$DATA_DIR/icons/default/index.theme"
fi &

rm -rf ~/.config/gtk-4.0/* ~/.config/gtk-3.0/settings.ini

mkdir -p "$HOME/.local/share/nwg-look" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
install "$ASSETDIR/gtk/gsettings" "$HOME/.local/share/nwg-look/gsettings"

# El comando falla cuando se invoca el script desde stage3.sh ($DISPLAY = nil)
is_chroot || dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

nwg-look -a 2>/dev/null
nwg-look -x 2>/dev/null

if [ ! -f "$CONF_DIR/gtk-3.0/bookmarks" ]; then
	cat <<-EOF >"$CONF_DIR/gtk-3.0/bookmarks"
		file://$HOME
		file://$HOME/Descargas
		file://$HOME/Documentos
		file://$HOME/Imágenes
		file://$HOME/Vídeos
		file://$HOME/Música
	EOF
fi

if [ ! -d /usr/local/share/themes/Gruvbox-Dark ]; then
	# https://www.pling.com/p/1681313/
	unzip "$ASSETDIR/gtk/Gruvbox-Dark-BL-LB.zip" -d "$TMP_DIR"/
	sudo /usr/bin/mkdir -p /usr/local/share/themes
	sudo /usr/bin/rm -rf /usr/local/share/themes/Gruvbox-*
	sudo /usr/bin/cp -rf "$TMP_DIR"/Gruvbox-Dark/ /usr/local/share/themes/
	sudo /usr/bin/cp -rf "$TMP_DIR"/Gruvbox-Dark-hdpi /usr/local/share/themes/
	sudo /usr/bin/cp -rf "$TMP_DIR"/Gruvbox-Dark-xhdpi /usr/local/share/themes/
fi &

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

#-------------------------------------------------------------------------------

LF_ETC="https://raw.githubusercontent.com/gokcehan/lf/master/etc"

download "$LF_ETC/colors.example" "$CONF_DIR/lf/colors" &
download "$LF_ETC/icons.example" "$CONF_DIR/lf/icons" &

wait # Esperamos a que nix-conf termine para que wine este disponible

[ ! -f "$WINEPREFIX/drive_c/windows/syswow64/mfc42.dll" ] && {
	is_chroot || winetricks -q mfc42
}

is_chroot || arkenfox-auto-update >/dev/null 2>&1
