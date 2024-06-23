# Customize character used in transient prompt history
function starship_transient_prompt_func
  starship module character
end

starship init fish | source
enable_transience

# Fix issues with transient prompt
## Only execute command if it isn't empty. Prevents issue where multiple prompts aren't cleared when hitting `enter`
## without a command entered.
function transient_execute_if_not_empty
  set -l command (commandline)
  if test -n "$command"
    transient_execute
  end
end
bind \r 'transient_execute_if_not_empty'
bind \n 'transient_execute_if_not_empty'
## Make `ctrl+c` clear the input. Prevents issue where the input along with the prompt wouldn't be cleared and instead
## a new prompt created
function cancel_and_repaint
  commandline ""
  commandline -f repaint
end
bind \cc 'cancel_and_repaint'
