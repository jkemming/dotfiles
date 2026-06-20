# Requirements

- [fish](https://fishshell.com/)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [mise](https://mise.jdx.dev/)
- A [Nerd Font](https://www.nerdfonts.com/) of your choice, e.g. JetBrains Mono

# Setup

1. Configure KDE Konsole:
    - Hide all toolbars under "Settings" → "Toolbars Shown"
    - Create a new profile:
        - Set `/usr/bin/fish` as command
        - Check "Default profile"
        - Uncheck "Appearance" → "Draw intense colors in bold font"
2. Navigate to the repository and run:
   ```shell
   mise install
   mise run install
   ```
