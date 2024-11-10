function keexp
	command keexp "$HOME/Nextcloud/KeePass/Credentials.kdbx" "$HOME/.config/keexp.json" | source
	function sudo
		SUDO_ASKPASS="$HOME/.config/echo_user_password" command sudo -A $argv
	end
end
