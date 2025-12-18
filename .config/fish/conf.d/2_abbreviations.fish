abbr -a g 'git'
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gb 'git branch'
abbr -a gbr 'git branch --remote'
abbr -a gc 'git commit'
abbr -a gco 'git checkout'
abbr -a gd 'git diff'
abbr -a gds 'git diff --staged'
abbr -a gf 'git fetch'
abbr -a gfr 'git fetch && git rebase'
abbr -a gl 'git pull'
abbr -a gp 'git push'
abbr -a gst 'git status'
abbr -a gsw 'git switch'
abbr -a l 'ls -lah --color'
abbr -a ls 'ls -lah --color'
abbr -a tf 'terraform'
abbr -a tfa 'terraform apply'
abbr -a tfi 'terraform init'
abbr -a tfp 'terraform plan'

# Allow going up multiple directories by typing multiple dots
function multicd
  echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add multicd --regex '^\.\.+$' --function multicd

# Allow repeating the last command with `!!`
function last_history_item
  echo $history[1]
end
abbr -a !! --position anywhere --function last_history_item
