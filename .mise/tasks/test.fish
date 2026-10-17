#!/usr/bin/env fish
#MISE description="Run the tests of the shims"

cargo test --locked --manifest-path shim/Cargo.toml $argv
