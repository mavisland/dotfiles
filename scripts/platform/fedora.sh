#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

install_platform_packages() {
	if ! command -v dnf >/dev/null 2>&1; then
		log "dnf is not available on this system."
		return 0
	fi

	local sudo_cmd=()
	if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
		if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
			sudo_cmd=(sudo)
		else
			log "sudo access is required for Fedora package installation."
			return 0
		fi
	fi

	log "Refreshing Fedora package metadata"
	"${sudo_cmd[@]}" dnf makecache

	log "Installing Fedora packages"
	"${sudo_cmd[@]}" dnf install -y git curl @development-tools ripgrep fd-find micro
}
