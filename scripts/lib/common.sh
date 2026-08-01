#!/usr/bin/env bash

log() {
  printf '[dotfiles] %s\n' "$*"
}

detect_os() {
  case "$(uname -s)" in
    Darwin)
      printf 'macos'
      ;;
    Linux)
      if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "${ID:-}" in
          ubuntu)
            printf 'ubuntu'
            ;;
          fedora)
            printf 'fedora'
            ;;
          *)
            printf '%s' "${ID:-linux}"
            ;;
        esac
      else
        printf 'linux'
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
      printf 'windows'
      ;;
    *)
      printf 'unknown'
      ;;
  esac
}
