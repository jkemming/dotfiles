#!/usr/bin/env fish
#MISE description="Fetch the SSH keys for git from the vault and store them in ~/.ssh"

set entry GitHub
set private_key_field 'SSH Private Key'
set public_key_field 'SSH Public Key'
set key ~/.ssh/github

mkdir -p ~/.ssh
chmod 700 ~/.ssh

set secrets (kgrant get --json $entry $private_key_field $public_key_field | string collect)
or exit

# Written to a temporary file first so that a failure doesn't leave a broken key behind. Keys must end in exactly one
# newline, no matter how the value is stored in the vault.
set filter '.[$field] | rtrimstr("\n") + "\n"'
umask 077
printf '%s' $secrets | jq --join-output --exit-status --arg field $private_key_field $filter >$key.new
and printf '%s' $secrets | jq --join-output --exit-status --arg field $public_key_field $filter >$key.pub.new
or begin
    rm -f $key.new $key.pub.new
    exit 1
end

chmod 644 $key.pub.new
mv $key.new $key
mv $key.pub.new $key.pub
