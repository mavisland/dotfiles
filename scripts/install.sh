#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
source "${script_dir}/lib/common.sh"

os_name="$(detect_os)"

case "${os_name}" in
  macos)
    source "${script_dir}/platform/macos.sh"
    install_platform_packages
    ;;
  ubuntu)
    source "${script_dir}/platform/ubuntu.sh"
    install_platform_packages
    ;;
  fedora)
    source "${script_dir}/platform/fedora.sh"
    install_platform_packages
    ;;
  *)
    log "Skipping platform package install for unsupported OS: ${os_name}"
    ;;
esac

install_symlink() {
  local source_path="$1"
  local target_path="$2"

  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    local backup_path="${target_path}.bak.$(date +%Y%m%d%H%M%S)"
    log "Backing up ${target_path} to ${backup_path}"
    mv "${target_path}" "${backup_path}"
  fi

  log "Linking ${target_path} -> ${source_path}"
  ln -s "${source_path}" "${target_path}"
}

log "Installing core dotfiles"
install_symlink "${repo_root}/config/git/.gitconfig" "${HOME}/.gitconfig"
install_symlink "${repo_root}/config/editor/.editorconfig" "${HOME}/.editorconfig"
install_symlink "${repo_root}/config/shell/.bashrc" "${HOME}/.bashrc"

log "Core install complete"