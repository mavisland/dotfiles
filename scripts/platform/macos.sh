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
	brew install \
		git \
		gh \
		ripgrep \
		fd \
		micro \
		stow \
		php \
		composer \
		mysql-client \
		sqlite \
		zsh-autosuggestions \
		zsh-syntax-highlighting

	install_nerd_font
}

install_nerd_font() {
	local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
	local fonts_dir="${HOME}/Library/Fonts"
	local temp_dir
	temp_dir="$(mktemp -d)"

	mkdir -p "${fonts_dir}"
	curl -L --fail --silent --show-error "${font_url}" -o "${temp_dir}/FiraCode.zip"
	unzip -o "${temp_dir}/FiraCode.zip" -d "${fonts_dir}"
	rm -rf "${temp_dir}"
}
