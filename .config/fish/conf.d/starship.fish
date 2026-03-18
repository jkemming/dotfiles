# Customize character used in transient prompt history
function starship_transient_prompt_func
  starship module character
end

starship init fish | source
enable_transience

# Override default `transient_execute` function to tweak the following:
#   - Prevent multiple prompts in case of invalid fish syntax (e.g. `echo "${test}"`)
#   - Prevent empty commands being executed by simply pressing `enter`
function transient_execute
  set -l command (commandline)
  if test -z "$command"
    return
  end

  set -g TRANSIENT 1
  set -g RIGHT_TRANSIENT 1
  commandline -f repaint
  commandline -f execute
end
# Prevent `ctrl-j` from printing multiple prompts
bind ctrl-j 'transient_execute'
