install:
  stow --restow --target="$HOME" .

uninstall:
  stow --delete --target="$HOME" .
