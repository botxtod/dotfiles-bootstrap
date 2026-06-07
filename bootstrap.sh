#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/botxtod/dotfiles.git"
WORKSPACE_DIR="$HOME/Documents/github_botxtod_workspace"
DOTFILES_DIR="$WORKSPACE_DIR/dotfiles"
CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"
CHEZMOI_CONFIG_FILE="$CHEZMOI_CONFIG_DIR/chezmoi.toml"

log() {
  printf '\n==> %s\n' "$*"
}

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf 'This bootstrap script is intended for macOS.\n' >&2
    exit 1
  fi
}

ensure_command_line_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    log "Xcode Command Line Tools are already installed"
    return
  fi

  log "Installing Xcode Command Line Tools"
  xcode-select --install || true
  printf '\nInstall Xcode Command Line Tools from the macOS dialog, then rerun this script.\n' >&2
  exit 1
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew is already installed"
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_bootstrap_tools() {
  log "Installing bootstrap tools"
  brew install gh chezmoi
}

ensure_github_login() {
  if gh auth status -h github.com >/dev/null 2>&1; then
    log "GitHub CLI is already authenticated"
    return
  fi

  log "Authenticating GitHub CLI"
  gh auth login -h github.com -p https -w
}

configure_chezmoi() {
  log "Configuring chezmoi source directory"
  mkdir -p "$WORKSPACE_DIR" "$CHEZMOI_CONFIG_DIR"
  printf '%s\n' 'sourceDir = "~/Documents/github_botxtod_workspace/dotfiles"' > "$CHEZMOI_CONFIG_FILE"
}

init_dotfiles() {
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    log "Updating existing dotfiles checkout"
    chezmoi git pull --ff-only
  else
    log "Initializing dotfiles from $DOTFILES_REPO"
    chezmoi init "$DOTFILES_REPO"
  fi
}

apply_dotfiles() {
  log "Previewing chezmoi changes"
  chezmoi diff || true

  log "Applying chezmoi configuration"
  chezmoi apply -v
}

main() {
  require_macos
  ensure_command_line_tools
  install_homebrew
  install_bootstrap_tools
  ensure_github_login
  configure_chezmoi
  init_dotfiles
  apply_dotfiles

  log "Bootstrap complete"
}

main "$@"
