#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

install_platform_packages() {
	if ! command -v brew >/dev/null 2>&1; then
		log "Homebrew is not installed. Install it first from https://brew.sh"
		return 0
	fi

	local repo_root
	repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

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
	install_vscode_extensions "${repo_root}"
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

install_vscode_extensions() {
	local repo_root="$1"
	local extensions_file="${repo_root}/config/vscode/extensions.txt"

	if [[ ! -f "${extensions_file}" ]]; then
		log "VS Code extensions list not found; skipping extension install."
		return 0
	fi

	if ! command -v code >/dev/null 2>&1; then
		log "code CLI is not available; skipping VS Code extension install."
		return 0
	fi

	log "Installing VS Code extensions"
	while IFS= read -r extension || [[ -n "${extension}" ]]; do
		if [[ -n "${extension}" ]]; then
			log "Installing VS Code extension: ${extension}"
			code --install-extension "${extension}" --force
		fi
	done < "${extensions_file}"
	log "VS Code extensions installed successfully"
}
