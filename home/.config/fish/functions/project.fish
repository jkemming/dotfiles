function project --description 'Jump to a repository or directory under ~/Projects'
    set -l root ~/Projects

    set -l selection (
        begin
            # Cloned repositories at arbitrary depth, without descending into them
            find $root/Repositories -name node_modules -prune -o -name .git -prune -printf '%h\n'
            # Other top-level directories
            find $root -mindepth 1 -maxdepth 1 -type d ! -name Repositories
        end \
            | string replace $root/ '' \
            | sort \
            | fzf --query "$argv" --select-1 --exit-0 --preview "ls -lah --color=always $root/{}"
    )
    and cd $root/$selection
end
