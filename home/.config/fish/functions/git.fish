function git
    set --local entry (command git config secrets.entry)
    set --local private_key_field (command git config secrets.privateKeyField)
    set --local public_key_field (command git config secrets.publicKeyField)

    if not contains -- "$argv[1]" am cherry-pick clone commit fetch ls-remote merge pull push rebase revert tag; or test -z "$entry" -o -z "$private_key_field" -o -z "$public_key_field"
        command git $argv
        return
    end

    set --local private_key (lab secret get $entry $private_key_field | string collect)
    test $pipestatus[1] -eq 0; or return
    set --local public_key (lab secret get $entry $public_key_field)
    or return
    with-ssh-keys "$private_key" -- command git -c (string escape -- "user.signingkey=key::$public_key") (string escape -- $argv)
end
