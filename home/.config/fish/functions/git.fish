function git
    set --local name (command git config ssh.keySecretName)
    set --local field (command git config ssh.keySecretField)

    if not contains -- "$argv[1]" clone fetch ls-remote pull push; or test -z "$name" -o -z "$field"
        command git $argv
        return
    end

    set --local key (lab secret get $name $field | string collect)
    test $pipestatus[1] -eq 0; or return
    with-ssh-keys "$key" -- command git (string escape -- $argv)
end
