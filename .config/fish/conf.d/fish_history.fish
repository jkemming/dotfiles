set -g __jkemming__automatic_private_mode_active false
set -g __jkemming__manual_private_mode_active false

function __jkemming__update_private_mode
    if test "$__jkemming__automatic_private_mode_active" = true; or test "$__jkemming__manual_private_mode_active" = true
        set -gx fish_private_mode true
    else
        set -ge fish_private_mode
    end
end

function __jkemming__update_automatic_private_mode --on-variable PWD --description 'Automatically enable private mode inside configured directories'
    set -l here (realpath $PWD 2>/dev/null)
    test -z "$here"; and set here $PWD

    for dir in $__jkemming__private_mode_directories
        set -l resolved (realpath $dir 2>/dev/null)
        test -z "$resolved"; and continue
        if test "$here" = "$resolved"; or string match -q -- "$resolved/*" "$here"
            set -g __jkemming__automatic_private_mode_active true
            __jkemming__update_private_mode
            return
        end
    end

    set -g __jkemming__automatic_private_mode_active false
    __jkemming__update_private_mode
end

function __jkemming__initialize_automatic_private_mode --on-event fish_prompt
    __jkemming__update_automatic_private_mode
    functions -e __jkemming__initialize_automatic_private_mode
end
