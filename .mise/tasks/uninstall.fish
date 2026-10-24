#!/usr/bin/env fish
#MISE description="Uninstall dotfiles from the home directory and remove the SSH keys"

mise dotfiles unapply --yes
and rm -f ~/.ssh/github ~/.ssh/github.pub
