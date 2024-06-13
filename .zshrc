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

## Suggestions
zinit light zsh-users/zsh-autosuggestions

## Snippets
zinit snippet OMZP::git

## Aliases
alias ll='ls -lah --color'

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

## Completion
# Match case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Color directories etc. properly
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
autoload -Uz compinit && compinit

## Syntax highlighting
# Must be at the end, see https://github.com/zsh-users/zsh-syntax-highlighting?tab=readme-ov-file#why-must-zsh-syntax-highlightingzsh-be-sourced-at-the-end-of-the-zshrc-file
zinit light zsh-users/zsh-syntax-highlighting

## History search
# Must be after syntax highlighting, see https://github.com/zsh-users/zsh-history-substring-search?tab=readme-ov-file#usage
zinit light zsh-users/zsh-history-substring-search
zinit ice wait atload'_history_substring_search_config'
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
