#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

source "${script_dir}/lib/common.sh"

os_name="$(detect_os)"
log "Detected OS: ${os_name}"

case "${os_name}" in
  macos)
    "${script_dir}/platform/macos.sh"
    ;;
  ubuntu)
    "${script_dir}/platform/ubuntu.sh"
    ;;
  fedora)
    "${script_dir}/platform/fedora.sh"
    ;;
  windows)
    log "Use install.ps1 on Windows for the PowerShell bootstrap path."
    ;;
  *)
    log "Unsupported OS: ${os_name}"
    exit 1
    ;;
esac
