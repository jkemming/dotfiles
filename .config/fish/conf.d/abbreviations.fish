abbr --all g 'git'
abbr --all ga 'git add'
abbr --all gaa 'git add --all'
abbr --all gb 'git branch'
abbr --all gbd 'git branch --delete --force'
abbr --all gbr 'git branch --remote'
abbr --all gc 'git commit'
abbr --all gcm 'git commit --message'
abbr --all gco 'git checkout'
abbr --all gd 'git diff'
abbr --all gds 'git diff --staged'
abbr --all gf 'git fetch'
abbr --all gfr 'git fetch && git rebase'
abbr --all gl 'git pull'
abbr --all gp 'git push'
abbr --all gr 'git rebase'
abbr --all gra 'git rebase --abort'
abbr --all grc 'git rebase --continue'
abbr --all gst 'git status'
abbr --all gsw 'git switch'
abbr --all gswc 'git switch --force-create'
abbr --all gswd 'git switch --detach'
abbr --all l 'ls'
abbr --all m 'mise'
abbr --all mr 'mise run'
abbr --all mt 'mise tasks'
abbr --all tf 'terraform'
abbr --all tfa 'terraform apply'
abbr --all tfi 'terraform init'
abbr --all tfp 'terraform plan'

# Allow going up multiple directories by typing multiple dots
function __jkemming__multicd
    echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add __jkemming__multicd --regex '^\.\.+$' --function __jkemming__multicd

# Allow repeating the last command with `!!`
function __jkemming__last_history_item
  echo $history[1]
end
abbr --add !! --position anywhere --function __jkemming__last_history_item
