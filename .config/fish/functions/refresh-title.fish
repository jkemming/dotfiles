function refresh-title
    # Only print title if actually connected to a terminal
    if isatty stdout
        fish_title | read -z title
        printf '\e]0;%s\e\\' "$title"
    end
end
