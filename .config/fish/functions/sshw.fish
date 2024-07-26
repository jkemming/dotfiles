function sshw
	if test (count $argv) -lt 1
		printf "Missing key.\nUsage: sshw [key] [ssh arguments]\n	"
		return 1
	end
	ssh-agent fish -c "echo '$argv[1]' | ssh-add - &>/dev/null && ssh $argv[2..-1]"
end
