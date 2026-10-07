status is-interactive; or return

abbr --add - 'cd -'
abbr --add g git
abbr --add ga 'git add'
abbr --add gaa 'git add --all'
abbr --add gb 'git branch'
abbr --add gbd 'git branch --delete --force'
abbr --add gbr 'git branch --remote'
abbr --add gc 'git commit'
abbr --add gca 'git commit --amend'
abbr --add gcm --set-cursor 'git commit --message "%"'
abbr --add gco 'git checkout'
abbr --add gd 'git diff'
abbr --add gds 'git diff --staged'
abbr --add gf 'git fetch'
abbr --add gfr 'git fetch && git rebase'
abbr --add gl 'git pull'
abbr --add gm 'git merge'
abbr --add gp 'git push'
abbr --add gr 'git rebase'
abbr --add gra 'git rebase --abort'
abbr --add grc 'git rebase --continue'
abbr --add gst 'git status'
abbr --add gsw 'git switch'
abbr --add gswc 'git switch --force-create'
abbr --add gswd 'git switch --detach'
abbr --add gwip --set-cursor 'git add --all && git commit --message "wip [skip ci]%" && git push'
abbr --add l ls
abbr --add m mise
abbr --add mi 'mise install'
abbr --add mr 'mise run'
abbr --add mt 'mise tasks'
abbr --add tf terraform
abbr --add tfa 'terraform apply'
abbr --add tfi 'terraform init'
abbr --add tfp 'terraform plan'

# Allow going up multiple directories by typing multiple dots
function __jkemming__multi_cd
    echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)'%'
end
abbr --add __jkemming__multi_cd --position anywhere --regex '^\.\.+$' --set-cursor --function __jkemming__multi_cd
