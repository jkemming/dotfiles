# Intentionally not set as universal variables (`set -U`) since that introduces persistent, untracked changes which
# hurt reproducibility on new systems where those changes haven't been applied.
set -g fish_greeting ''

fish_config theme choose default-rgb

function __disable_history_check --on-variable PWD --description 'Disable fish history inside configured directories'
    set -l here (realpath $PWD 2>/dev/null)
    test -z "$here"; and set here $PWD

    for dir in $__disable_history_dirs
        set -l resolved (realpath $dir 2>/dev/null)
        test -z "$resolved"; and continue
        if test "$here" = "$resolved"; or string match -q -- "$resolved/*" "$here"
            if not set -q fish_private_mode
                set -g fish_private_mode automatic
            end
            return
        end
    end

    if test "$fish_private_mode" = automatic
        set -e fish_private_mode
    end
end

function __disable_history_startup --on-event fish_prompt
    __disable_history_check
    functions -e __disable_history_startup
end
