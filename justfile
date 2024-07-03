set shell := ["fish", "-c"]

install:
  stow --restow --target="$HOME" .

uninstall:
  stow --delete --target="$HOME" .

prune:
  #!/usr/bin/env fish
  set broken_symlinks (find -L "$HOME" -type l 2>/dev/null)
  for broken_symlink in $broken_symlinks
    set target (readlink -f "$broken_symlink")
    if not string match -q '{{justfile_directory()}}/*' "$target"
      continue
    end
    echo "Delete broken symlink: $broken_symlink ➜ $target"
    read -P '[y/n]: ' confirm_delete
    if test "$confirm_delete" = "y"
      rm "$broken_symlink"
    end
  end
