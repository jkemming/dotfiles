function __jkemming__update_automatic_private_mode --on-variable PWD --description 'Disable fish history inside configured directories'
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

function __jkemming__initialize_automatic_private_mode --on-event fish_prompt
    __jkemming__update_automatic_private_mode
    functions -e __jkemming__initialize_automatic_private_mode
end
