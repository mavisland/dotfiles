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
}
