#!/usr/bin/env fish
#MISE description="Install dotfiles to the home directory, install the tools and fetch the SSH keys"

# The tools are only configured once the dotfiles are applied, and the keys need `kgrant` from them
mise dotfiles apply --prune --yes
and mise install
and mise run keys
