function sudo
    SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass" command sudo -EA $argv
end
