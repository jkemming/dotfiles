function refresh-title
    fish_title | read -z title
    printf '\e]0;%s\e\\' "$title"
end
