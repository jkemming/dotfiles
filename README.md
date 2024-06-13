* Install GNU stow
	* Create config symlinks: `stow --restow --target="${HOME}" .`
* Install zsh
* Install [Starship](https://starship.rs/)
* Install a [Nerd Font](https://www.nerdfonts.com/), e.g. JetBrains Mono
* Configure Konsole profile to use zsh and Nerd Font
	* Uncheck "Appearance" > "Draw intense colors in bold font"
* Change login shell to zsh: `chsh -s '/usr/bin/zsh' $USER`
* Install [mise](https://mise.jdx.dev/)
	* Install configured tools: `mise install`
