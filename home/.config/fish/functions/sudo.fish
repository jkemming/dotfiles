function sudo
    SUDO_ASKPASS="$HOME/.config/sudo-askpass" command sudo -EA $argv
end
