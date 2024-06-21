## mise-en-place
mise activate fish | source

## Starship
function starship_transient_prompt_func
  starship module character
end
starship init fish | source
enable_transience

## Configuration overrides
set -g fish_greeting ''

## Environment variables
set -gx EDITOR 'nano'
set -gx VISUAL 'nano'

## Key bindings
# Only execute command if it isn't empty - prevents issue where prompt isn't cleared in transient mode if command is empty
bind \r 'if test -n "(commandline)"; transient_execute; end'
# Make `ctrl+c` clear the input - prevents issue where the input along with the prompt wouldn't be cleared and instead a new prompt created
bind \cc 'commandline ""'

## Abbreviations
function multicd
  echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add multicd --regex '^\.\.+$' --function multicd

abbr -a g git
abbr -a ga git add
abbr -a gaa git add --all
abbr -a gb git branch
abbr -a gbr git branch --remote
abbr -a gc git commit
abbr -a gco git checkout
abbr -a gd git diff
abbr -a gds git diff --staged
abbr -a gf git fetch
abbr -a gl git pull
abbr -a gp git push
abbr -a gst git status
abbr -a gsw git switch
abbr -a l ls -lah
abbr -a tf terraform
abbr -a tfa terraform apply
abbr -a tfi terraform init
abbr -a tfp terraform plan
