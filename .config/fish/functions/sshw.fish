function sshw -d 'Run SSH with the given arguments, making the given SSH key available to it'
	if test (count $argv) -lt 1
		printf 'Invalid arguments.\nUsage: sshw key [ssh arguments ...]\n'
		return 1
	end
	with-ssh-keys $argv[1] -- ssh -o PasswordAuthentication=no $argv[2..-1]
end
