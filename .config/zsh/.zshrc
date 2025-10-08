# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh/aliasrc

bindkey -e

# Autocompletación con TAB
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Incluir archivos ocultos

# Tipo de autocompletación
autoload -U select-word-style
select-word-style bash

# Cambiar directorios con lf (Ctrl+O)
lfcd () {
	tmp="$(mktemp)"
	lf -last-dir-path="$tmp" "$@"
	if [ -f "$tmp" ]; then
		dir="$(cat "$tmp")"
		rm -f "$tmp"
		[ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
	fi
}
bindkey -s '^o' 'lfcd\n'

HISTSIZE=512
SAVEHIST=512

# Bindings de teclado
bindkey  "^[[3~" delete-char

bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

function get_time {
	date +'%H:%M:%S'
}
function parse_git_branch() {
  git branch 2>/dev/null | grep '^*' | colrm 1 2
}
function git_prompt_info() {
  local branch=$(parse_git_branch)
  [[ -n $branch ]] && echo "%F{yellow}($branch)%f"
}
PROMPT='%F{magenta}%~%f $(git_prompt_info)%f$ '

RPROMPT='$(get_time)'

setopt promptsubst

printf '\033[?1h\033=' >/dev/tty

source "$HOME/.profile"
