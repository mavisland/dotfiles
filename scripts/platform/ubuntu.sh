#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

install_platform_packages() {
	if ! command -v apt-get >/dev/null 2>&1; then
		log "apt-get is not available on this system."
		return 0
	fi

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
