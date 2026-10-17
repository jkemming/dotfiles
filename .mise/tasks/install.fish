#!/usr/bin/env fish
#MISE description="Build the shims and install dotfiles to the home directory"

cargo build --release --locked --manifest-path shim/Cargo.toml
or exit

mkdir -p home/.local/bin
cp shim/target/release/git shim/target/release/sudo home/.local/bin/

mise dotfiles apply --prune --yes
