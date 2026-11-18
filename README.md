# Overview

These are my dotfiles I use with Fedora and KDE Konsole.


# Requirements

- [fish](https://fishshell.com/)
- [mise](https://mise.jdx.dev/)
- A [Nerd Font](https://www.nerdfonts.com/) of your choice, e.g. JetBrains Mono


# Install

On a fresh machine, first [bootstrap](docs/bootstrapping.md) the repository.

```shell
mise run install
mise install
```


# Manual setup

Some settings on Fedora KDE can't be synced and have to be configured by hand, see [docs/manual-setup.md](docs/manual-setup.md).


# Uninstall

```shell
mise run uninstall
```
