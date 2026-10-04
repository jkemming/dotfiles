mise activate fish | source
mise completion fish | source

functions -c mise __jkemming__original_mise

function mise
    if test (count $argv) -ge 2; and test "$argv[1]" = run
        set -l task $argv[2]
        set-title "mise run $task"
        refresh-title
        __jkemming__original_mise $argv
        set -l status_code $status
        unset-title
        return $status_code
    else
        __jkemming__original_mise $argv
    end
end
