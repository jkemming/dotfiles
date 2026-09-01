functions -c fish_title __jkemming__original_fish_title

function fish_title
    if set -q fish_private_mode
        echo -n "🕶️ "
    end
    if set -q __jkemming__shell_title_override
        echo $__jkemming__shell_title_override
    else
        __jkemming__original_fish_title $argv
    end
end
