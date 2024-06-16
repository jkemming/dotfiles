## Starship
eval "$(starship init zsh)"

## Mise
eval "$(mise activate zsh)"

## Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

## Key bindings
bindkey -e

## Syntax highlighting
zinit light zdharma-continuum/fast-syntax-highlighting
# Don't highlight copy-pasted text
zle_highlight=('paste:none')

## Auto completion
zinit light marlonrichert/zsh-autocomplete

## Snippets
zinit snippet OMZP::git

## Aliases
alias ll='ls -lah --color'
alias keexp='eval $(/usr/local/bin/keexp "${HOME}/Nextcloud/KeePass/Credentials.kdbx" "${HOME}/Nextcloud/keexp_config.json")'

## History
HISTSIZE='5000'
HISTFILE="${HOME}/.zsh_history"
SAVEHIST="${HISTSIZE}"
HISTDUP='erase'
setopt APPEND_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
