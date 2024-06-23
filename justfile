set shell := ["fish", "-c"]

install:
  stow --restow --target="$HOME" .

uninstall:
  stow --delete --target="$HOME" .

prune:
  #!/usr/bin/env fish
  set broken_symlinks (find -L "$HOME" -type l)
  for broken_symlink in $broken_symlinks
    echo "Delete broken symlink: $broken_symlink"
    read -P '[y/n]: ' confirm_delete
    if test "$confirm_delete" = "y"
      rm "$broken_symlink"
    end
  end
