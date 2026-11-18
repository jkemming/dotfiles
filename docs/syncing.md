# Syncing dotfiles

The files in `home/` are the source of truth. They are mirrored into the home directory (e.g. `home/.config/opencode/AGENTS.md` becomes `~/.config/opencode/AGENTS.md`) by:

```shell
mise run install
```

The task is defined in `.mise/tasks/install.fish`.

## Rules for editing

- **Only edit files in this repository.** Files in the target directories (`~/.config/opencode/`, etc.) are generated output. Changes made there are overwritten the next time the install task runs and are never committed.
- After changing something in `home/`, run `mise run install` to apply it.
- The install task prunes files it previously installed that no longer exist in the repository, so deleting a file here also removes it from the target.
- `mise run uninstall` removes the installed files again.
