function with-ssh-keys -d 'Run the given command, making the given SSH keys available to it'
	if \
		begin
			not set -f separator_index (contains -i -- '--' $argv) # Ensure separator is present
			or test $separator_index -eq 1 # Ensure at least one key is present
			or test (count $argv) -lt (math $separator_index + 1) # Ensure command is present
		end
		printf 'Invalid arguments.\nUsage: with-ssh-keys key [additional keys ...] -- command [arguments ...]\n'
		return 1
	end

	set -f command
	set -f keys $argv[1..(math $separator_index - 1)]
	for key in $keys
		if not string match -re -- '^-----BEGIN OPENSSH PRIVATE KEY-----[\\s\\S]+-----END OPENSSH PRIVATE KEY-----$' "$key" &>/dev/null
			set -f key_index (contains -i -- $key $keys)
			printf "SSH key $key_index is not a valid OpenSSH private key.\n"
			return 2
		end
		set -a command "echo '$key' | ssh-add - &>/dev/null && "
	end
	set -a command $argv[(math $separator_index + 1)..-1]
	ssh-agent fish -c "$command"
end
