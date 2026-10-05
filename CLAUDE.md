# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for Fedora + KDE Konsole, centered on the fish shell and managed with GNU Stow and mise. There is no build or test suite.

## Commands

- `mise run sync` — stow `home/` into `$HOME` and regenerate `~/.config/git/includes.config`
- `mise run sync --prune` — additionally prune orphaned symlinks from renamed/moved files (slower; does not remove empty directories)
- `mise run unsync` — remove the symlinks and `includes.config`

Tasks live in `mise/tasks/` (executable fish scripts with `#MISE` / `#USAGE` header comments), not in a `mise.toml`.

## Architecture

- `home/` mirrors `$HOME`. Stow runs with `--no-folding`, so individual files (not whole directories) are symlinked. Adding a file under `home/` and re-running `mise run sync` is all that's needed to deploy it. Editing a file in `home/` takes effect immediately because the target is a symlink.
- `home/.config/fish/conf.d/` holds startup config; `home/.config/fish/functions/` holds one autoloaded function per file (filename = function name). Abbreviations are in `conf.d/abbreviations.fish`.
- Private mode (`conf.d/fish_private_mode.fish`) combines an automatic mode (PWD inside any directory in `$__jkemming__private_mode_directories`) with a manual one (`enable-private-mode` / `disable-private-mode`), and exports `fish_private_mode` accordingly. Internal helpers use the `__jkemming__` prefix.
- Git config is split: `home/.config/git/config` is stowed, while `~/.config/git/includes.config` is *generated* by the sync task from `~/.config/git/conf.d/*.config` snippets (not in this repo). Each snippet's first line must be `# directory = <gitdir pattern>`; it becomes an `[includeIf "gitdir:..."]` entry. Snippets without the header are skipped with a warning.
- `home/.config/mise/config.toml` declares the global toolchain (fzf, starship, node, java, etc.).
- `home/.claude/settings.json` is the user's global Claude Code settings, deployed via stow.
- `project` (fish function) fuzzy-finds repositories under `~/Projects/Repositories` and other top-level dirs in `~/Projects` using fzf.
