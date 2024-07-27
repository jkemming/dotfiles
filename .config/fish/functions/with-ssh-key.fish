function with-ssh-key -d 'Run the given command, making the given SSH key available to it'
	if test (count $argv) -lt 2
		printf 'Insufficient arguments.\nUsage: with-ssh-key key command [arguments ...]\n'
		return 1
	end

	if not string match -re -- '^-----BEGIN OPENSSH PRIVATE KEY-----[\\s\\S]+-----END OPENSSH PRIVATE KEY-----$' "$argv[1]" &>/dev/null
		echo 'Given SSH key is not a valid OpenSSH private key.'
		return 2
	end

	ssh-agent fish -c "echo '$argv[1]' | ssh-add - &>/dev/null && $argv[2..-1]"
end
