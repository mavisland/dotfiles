# Shared interactive shell defaults
if [[ -f "$HOME/.shell-env" ]]; then
  . "$HOME/.shell-env"
fi

__dotfiles_git_branch() {
  local branch_name
  branch_name="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ -n "${branch_name}" && "${branch_name}" != "HEAD" ]]; then
    printf ' (%s)' "${branch_name}"
  fi
}

if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
  elif [[ -r /usr/local/etc/profile.d/bash_completion.sh ]]; then
    . /usr/local/etc/profile.d/bash_completion.sh
  fi

  if [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  elif [[ -r /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi

  if [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  elif [[ -r /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi
fi

export HISTSIZE=10000
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'

PROMPT='%n@%m:%~$(__dotfiles_git_branch) %# '

if [ -f "$HOME/.shell_local" ]; then
  source "$HOME/.shell_local"
fi