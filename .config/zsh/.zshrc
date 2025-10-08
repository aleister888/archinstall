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
	DIR="$(find . | fzf --reverse --header='Ir a la localización')"
	[ -d "$DIR" ] && cd "$DIR"
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

PROMPT='%F{magenta}%~%f $(git_prompt_info)%f%% '
setopt promptsubst
