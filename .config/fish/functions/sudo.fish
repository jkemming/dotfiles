function sudo
	if set -q USER_PASSWORD
		SUDO_ASKPASS="$HOME/.config/echo_user_password" command sudo -A $argv
	else
		command sudo $argv
	end
end
