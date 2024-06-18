mise activate fish | source
starship init fish | source

# Configuration overrides
set -g fish_greeting ''

# Abbreviations
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
abbr -a gp git push
abbr -a gst git status
abbr -a gsw git switch
abbr -a l ls -lah
