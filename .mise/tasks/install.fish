#!/usr/bin/env fish
#MISE description="Build the shims and install dotfiles to the home directory"

cargo build --release --locked --manifest-path shim/Cargo.toml
or exit

mise dotfiles apply --prune --yes
