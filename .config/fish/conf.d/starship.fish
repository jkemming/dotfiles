# Customize character used in transient prompt history
function starship_transient_prompt_func
  starship module character
end

starship init fish | source
enable_transience

# Only execute command if it isn't empty. Prevents issue where multiple prompts aren't cleared when hitting `enter`
# without a command entered.
function transient_execute_if_not_empty
  set -l command (commandline)
  if test -n "$command"
    transient_execute
  end
end
bind enter 'transient_execute_if_not_empty'
