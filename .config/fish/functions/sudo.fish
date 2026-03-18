function sudo
	if set -q USER_PASSWORD
		SUDO_ASKPASS="$HOME/.config/echo_user_password" command sudo -EA $argv
	else
		command sudo -E $argv
	end
end
