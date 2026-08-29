functions -c fish_title __original_fish_title

function fish_title
    if set -q __shell_title_override
        echo $__shell_title_override
    else
        __original_fish_title $argv
    end
end
