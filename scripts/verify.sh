#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

echo "[dotfiles] Validating shell scripts"
bash -n \
  "${repo_root}/scripts/install.sh" \
  "${repo_root}/scripts/bootstrap.sh" \
  "${repo_root}/scripts/platform/macos.sh" \
  "${repo_root}/scripts/platform/ubuntu.sh" \
  "${repo_root}/scripts/platform/fedora.sh" \
  "${repo_root}/scripts/lib/common.sh"

echo "[dotfiles] Validating JSON config"
python -m json.tool "${repo_root}/config/vscode/settings.json" > /dev/null
python -m json.tool "${repo_root}/config/terminal/windows-terminal/settings.json" > /dev/null
python -m json.tool "${repo_root}/config/composer/.config/composer/composer.json" > /dev/null

if command -v plutil >/dev/null 2>&1; then
  echo "[dotfiles] Validating plist config"
  plutil -lint "${repo_root}/config/terminal/macos-terminal/com.apple.Terminal.plist"
  plutil -lint "${repo_root}/config/terminal/iterm2/com.googlecode.iterm2.plist"
fi

if command -v composer >/dev/null 2>&1; then
  echo "[dotfiles] Validating Composer config"
  COMPOSER_HOME="${repo_root}/config/composer/.config/composer" composer validate --no-check-publish --no-interaction
fi

if command -v php >/dev/null 2>&1; then
  echo "[dotfiles] Validating PHP override config"
  PHP_INI_SCAN_DIR="${repo_root}/config/php/.config/php/conf.d" php --ri date >/dev/null
fi

echo "[dotfiles] Verification complete"