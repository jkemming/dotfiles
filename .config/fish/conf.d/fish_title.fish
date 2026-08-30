functions -c fish_title __original_fish_title

function fish_title
    if set -q fish_private_mode
        echo -n "🕶️ "
    end
    if set -q __shell_title_override
        echo $__shell_title_override
    else
        __original_fish_title $argv
    end
end
