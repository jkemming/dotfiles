function __jkemming__abbr --description 'Define a global + optional command-scoped abbreviation'
    set -l flags
    set -l rest $argv
    while set -q rest[1]
        if not string match -q -- '-*' $rest[1]
            break
        end
        set -a flags $rest[1]
        set -e rest[1]
    end

    if not contains -- (count $rest) 2 4
        echo "Usage: __jkemming__abbr [abbr-flags...] <command> <command-abbreviation> [<subcommand> <subcommand-abbreviation>]" >&2
        return 1
    end

    set -l cmd_abbr $rest[1]
    set -l cmd $rest[2]

    if test (count $rest) -eq 2
        abbr --add $flags $cmd_abbr $cmd
        return 0
    end

    set -l sub_abbr $rest[3]
    set -l sub $rest[4]

    abbr --add $flags $cmd_abbr$sub_abbr "$cmd $sub"
    abbr --add --command $cmd $flags $sub_abbr "$sub"
end

# Single-command abbreviations
__jkemming__abbr g git
__jkemming__abbr g git a 'add'
__jkemming__abbr g git aa 'add --all'
__jkemming__abbr g git b 'branch'
__jkemming__abbr g git bd 'branch --delete --force'
__jkemming__abbr g git br 'branch --remote'
__jkemming__abbr g git c 'commit'
__jkemming__abbr g git ca 'commit --amend'
__jkemming__abbr --set-cursor g git cm 'commit --message "%"'
__jkemming__abbr g git co 'checkout'
__jkemming__abbr g git d 'diff'
__jkemming__abbr g git ds 'diff --staged'
__jkemming__abbr g git f 'fetch'
__jkemming__abbr g git l 'pull'
__jkemming__abbr g git p 'push'
__jkemming__abbr g git r 'rebase'
__jkemming__abbr g git ra 'rebase --abort'
__jkemming__abbr g git rc 'rebase --continue'
__jkemming__abbr g git st 'status'
__jkemming__abbr g git sw 'switch'
__jkemming__abbr g git swc 'switch --force-create'
__jkemming__abbr g git swd 'switch --detach'
__jkemming__abbr l ls
__jkemming__abbr m mise
__jkemming__abbr m mise r 'run'
__jkemming__abbr m mise t 'tasks'
__jkemming__abbr tf terraform
__jkemming__abbr tf terraform a 'apply'
__jkemming__abbr tf terraform i 'init'
__jkemming__abbr tf terraform p 'plan'

# Complex abbreviations
abbr --add gfr 'git fetch && git rebase'
abbr --add --set-cursor gwip 'git add --all && git commit --message "wip [skip ci]%" && git push'

# Allow going up multiple directories by typing multiple dots
function __jkemming__multi_cd
    echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)'%'
end
abbr --add __jkemming__multi_cd --position anywhere --regex '^\.\.+$' --set-cursor --function __jkemming__multi_cd

# Allow repeating the last command with `!!`
function __jkemming__last_history_item
  echo $history[1]
end
abbr --add !! --position anywhere --function __jkemming__last_history_item
