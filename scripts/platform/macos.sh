#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

install_platform_packages() {
	if ! command -v brew >/dev/null 2>&1; then
		log "Homebrew is not installed. Install it first from https://brew.sh"
		return 0
	fi

	log "Updating Homebrew"
	brew update

	log "Installing macOS packages"
	brew install git gh ripgrep fd micro zsh-autosuggestions zsh-syntax-highlighting
}
