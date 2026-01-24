# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh/aliasrc
source "$HOME/.profile"

bindkey -e

# Autocompletación con TAB
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Incluir archivos ocultos

# Interpretar '/' como delimitador
WORDCHARS=${WORDCHARS//\//}

function fzf_dir() {
	local SELECTED="$(find . | fzf --reverse --header='Ir a la localización')"
	[ -d "$SELECTED" ] && cd "$SELECTED"
	[ -f "$SELECTED" ] && cd $(dirname "$SELECTED")
}

# Bindings de teclado
bindkey -s '^o' 'fzf_dir\n'
bindkey "^[[3~" delete-char
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Comando no encontrado: formatear mensaje
function command_not_found_handler() {
	echo "$1 not found in \$PATH"
}

printf '\033[?1h\033=' >/dev/tty

#############
# Historial #
#############

HISTSIZE=10000              # Líneas de historial en memoria
SAVEHIST=10000              # Líneas de historial que se guardan en el archivo
setopt hist_ignore_dups     # Ignorar duplicados consecutivos
setopt hist_ignore_all_dups # No guardar líneas duplicadas
setopt hist_reduce_blanks   # Quitar espacios extra
setopt hist_verify          # Verifica antes de ejecutar desde el historial
setopt share_history        # Comparte historial entre sesiones
setopt append_history       # Añade al archivo, no lo sobrescribe
setopt inc_append_history   # Guarda los comandos al ejecutarlos

##########
# Prompt #
##########

function parse_git_branch() {
	git branch 2>/dev/null | grep '^*' | colrm 1 2
}

function git_prompt_info() {
	local branch=$(parse_git_branch)
	[[ -n $branch ]] && echo "%F{yellow}($branch)%f"
}

PROMPT='%F{magenta}%~%f $(git_prompt_info)%f$ '
setopt promptsubst

echo "$(date '+%A %d de %B'); $(uptime -p)"
echo "pacman: $(yay -Q | wc -l) (aur: $(yay -Qm | wc -l)), nix: $(nix profile list --json | jq -c '.elements | to_entries[]' | wc -l)"
