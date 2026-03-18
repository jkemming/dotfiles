function sudo
	if set -q USER_PASSWORD
		SUDO_ASKPASS="$HOME/.config/echo_user_password" command sudo -eA $argv
	else
		command sudo -e $argv
	end
end
