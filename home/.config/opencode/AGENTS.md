# Personal instructions

## Directory layout

- `~/Projects` follows the XDG `Projects` directory convention and is the root of the OpenCode project. It is not a git repository itself.
- `~/Projects/Repositories` holds all git repositories, laid out as `Repositories/<host>/<owner>/<repo>` (e.g. `Repositories/github.com/jkemming/<repo>`).
- Each repository is its own git repository. Run git commands inside the repository, not at the `Projects` root.

## Git commits

- Use [Conventional Commits](https://www.conventionalcommits.org/).
- Never add an AI as a co-author (no `Co-authored-by` trailer for an AI, and no "Generated with …" footer). AIs are not natural persons and cannot hold authorship.
- When asked to commit, follow the `commit` skill.
