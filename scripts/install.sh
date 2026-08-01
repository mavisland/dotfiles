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

  if [[ -L "${target_path}" && "$(readlink "${target_path}")" == "${source_path}" ]]; then
    log "Skipping ${target_path}; already linked to ${source_path}"
    return
  fi

  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    local backup_path="${target_path}.bak.$(date +%Y%m%d%H%M%S)"
    log "Backing up ${target_path} to ${backup_path}"
    mv "${target_path}" "${backup_path}"
  fi

  log "Linking ${target_path} -> ${source_path}"
  ln -s "${source_path}" "${target_path}"
}

install_stow_package() {
  local package_name="$1"

  if command -v stow >/dev/null 2>&1; then
    if [[ -e "${HOME}/.ssh/config" && ! -L "${HOME}/.ssh/config" ]]; then
      local backup_path="${HOME}/.ssh/config.bak.$(date +%Y%m%d%H%M%S)"
      log "Backing up ${HOME}/.ssh/config to ${backup_path}"
      mv "${HOME}/.ssh/config" "${backup_path}"
    fi

    log "Stowing ${package_name}"
    (cd "${repo_root}/config" && stow -t "${HOME}" "${package_name}")
    return
  fi

  log "stow is not available; linking ${package_name} manually"
  mkdir -p "${HOME}/.ssh"
  install_symlink "${repo_root}/config/${package_name}/.ssh/config" "${HOME}/.ssh/config"
}

install_vscode_settings() {
  local settings_source="${repo_root}/config/vscode/settings.json"
  local target_path=""

  case "${os_name}" in
    macos)
      target_path="${HOME}/Library/Application Support/Code/User/settings.json"
      ;;
    ubuntu|fedora)
      if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
        target_path="${XDG_CONFIG_HOME}/Code/User/settings.json"
      else
        target_path="${HOME}/.config/Code/User/settings.json"
      fi
      ;;
    *)
      return
      ;;
  esac

  mkdir -p "$(dirname "${target_path}")"
  install_symlink "${settings_source}" "${target_path}"
}

log "Installing core dotfiles"
install_symlink "${repo_root}/config/shell/.shell-env" "${HOME}/.shell-env"
install_symlink "${repo_root}/config/git/.gitignore_global" "${HOME}/.gitignore_global"
install_symlink "${repo_root}/config/git/.gitconfig" "${HOME}/.gitconfig"
install_symlink "${repo_root}/config/editor/.editorconfig" "${HOME}/.editorconfig"
install_symlink "${repo_root}/config/shell/.bashrc" "${HOME}/.bashrc"
install_symlink "${repo_root}/config/shell/.bash_completion" "${HOME}/.bash_completion"
install_symlink "${repo_root}/config/shell/.zshrc" "${HOME}/.zshrc"
install_symlink "${repo_root}/config/shell/.profile" "${HOME}/.profile"
install_symlink "${repo_root}/config/shell/.bash_profile" "${HOME}/.bash_profile"
install_stow_package "ssh"
install_vscode_settings

install_macos_terminal_settings() {
  local prefs_dir="${HOME}/Library/Preferences"
  local terminal_source="${repo_root}/config/terminal/macos-terminal/com.apple.Terminal.plist"
  local iterm_source="${repo_root}/config/terminal/iterm2/com.googlecode.iterm2.plist"

  mkdir -p "${prefs_dir}"

  if [[ -f "${terminal_source}" ]]; then
    install_symlink "${terminal_source}" "${prefs_dir}/com.apple.Terminal.plist"
  fi

  if [[ -f "${iterm_source}" ]]; then
    install_symlink "${iterm_source}" "${prefs_dir}/com.googlecode.iterm2.plist"
  fi
}

if [[ "${os_name}" == "macos" ]]; then
  install_macos_terminal_settings
fi

log "Core install complete"