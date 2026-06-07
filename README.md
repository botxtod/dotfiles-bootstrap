# dotfiles-bootstrap

Public bootstrap script for setting up a new macOS machine with the private
`botxtod/dotfiles` chezmoi repository.

Run on a new Mac:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/botxtod/dotfiles-bootstrap/main/bootstrap.sh)"
```

The script installs Homebrew if needed, installs `gh` and `chezmoi`, authenticates
GitHub CLI, initializes the private dotfiles repository, and applies it with
chezmoi.

No secrets or personal dotfiles are stored in this public repository.
