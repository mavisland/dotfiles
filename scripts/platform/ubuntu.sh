#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

install_platform_packages() {
	if ! command -v apt-get >/dev/null 2>&1; then
		log "apt-get is not available on this system."
		return 0
	fi

	local repo_root
	repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

	local sudo_cmd=()
	if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
		if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
			sudo_cmd=(sudo)
		else
			log "sudo access is required for Ubuntu package installation."
			return 0
		fi
	fi

	log "Updating apt package lists"
	"${sudo_cmd[@]}" apt-get update

	log "Installing Ubuntu packages"
	"${sudo_cmd[@]}" apt-get install -y \
		git \
		curl \
		unzip \
		build-essential \
		stow \
		ripgrep \
		fd-find \
		micro \
		php-cli \
		php-curl \
		php-mbstring \
		php-xml \
		composer \
		default-mysql-client \
		sqlite3

	install_nerd_font
	install_vscode_extensions "${repo_root}"
}

install_nerd_font() {
	local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
	local fonts_dir="${HOME}/.local/share/fonts/FiraCodeNerdFont"
	local temp_dir
	temp_dir="$(mktemp -d)"

	mkdir -p "${fonts_dir}"
	curl -L --fail --silent --show-error "${font_url}" -o "${temp_dir}/FiraCode.zip"
	unzip -o "${temp_dir}/FiraCode.zip" -d "${fonts_dir}"
	if command -v fc-cache >/dev/null 2>&1; then
		fc-cache -f -v >/dev/null
	fi
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
