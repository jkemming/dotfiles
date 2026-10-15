function git
    set --local entry (command git config secrets.entry)
    set --local private_key_field (command git config secrets.privateKeyField)
    set --local public_key_field (command git config secrets.publicKeyField)

    if not contains -- "$argv[1]" am cherry-pick clone commit fetch ls-remote merge pull push rebase revert tag; or test -z "$entry" -o -z "$private_key_field" -o -z "$public_key_field"
        command git $argv
        return
    end

    set --local secrets (kgrant get --json $entry $private_key_field $public_key_field)
    or return
    set --local private_key (printf '%s' $secrets | jq --raw-output --arg field $private_key_field '.[$field]' | string collect)
    set --local public_key (printf '%s' $secrets | jq --raw-output --arg field $public_key_field '.[$field]')
    set --local --export SSH_PRIVATE_KEY $private_key
    ssh-agent fish --no-config --command 'printf "%s\n" $SSH_PRIVATE_KEY | ssh-add - &>/dev/null; and set --erase SSH_PRIVATE_KEY; and command git -c "user.signingkey=key::$argv[1]" $argv[2..-1]' $public_key $argv
end
