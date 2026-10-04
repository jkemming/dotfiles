function clone --description 'Clone a repository into ~/Projects/Repositories/<host>/<owner>/<repo>'
    if test (count $argv) -ne 1
        echo "Usage: clone <url|owner/repo>" >&2
        return 1
    end

    set -l url $argv[1]
    # Shorthand `owner/repo` defaults to GitHub
    if string match --quiet --regex '^[^/:@]+/[^/:@]+$' -- $url
        set url git@github.com:$url.git
    end

    # Turn the URL into `<host>/<path>` by dropping the protocol (`https://`),
    # username (`git@`) and `.git` suffix
    set -l repo_path (string replace --regex '^(?:[a-z+]+://)?(?:[^@/]*@)?([^:/]+)[:/](.+?)(?:\.git)?/?$' '$1/$2' -- $url)
    set -l target ~/Projects/Repositories/$repo_path

    if test -e $target
        echo "$target already exists" >&2
        return 1
    end

    git clone $url $target
    and cd $target
end
