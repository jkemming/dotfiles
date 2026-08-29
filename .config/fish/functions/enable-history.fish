function enable-history
	set -ge fish_private_mode
	# Run check to ensure automatic disabling is applied
	__disable_history_check
end
