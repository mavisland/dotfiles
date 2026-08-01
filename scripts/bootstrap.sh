#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

source "${script_dir}/lib/common.sh"

os_name="$(detect_os)"
log "Detected OS: ${os_name}"

case "${os_name}" in
  macos)
    bash "${script_dir}/install.sh"
    ;;
  ubuntu)
    bash "${script_dir}/install.sh"
    ;;
  fedora)
    bash "${script_dir}/install.sh"
    ;;
  windows)
    log "Use install.ps1 on Windows for the PowerShell bootstrap path."
    ;;
  *)
    log "Unsupported OS: ${os_name}"
    exit 1
    ;;
esac
