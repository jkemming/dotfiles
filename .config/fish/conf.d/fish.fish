# Intentionally not set as universal variables (`set -U`) since that introduces persistent, untracked changes which
# hurt reproducibility on new systems where those changes haven't been applied.
set -g fish_greeting ''

fish_config theme choose default-rgb
