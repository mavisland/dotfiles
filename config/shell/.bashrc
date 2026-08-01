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

export HISTCONTROL=ignoreboth
export HISTSIZE=10000
export HISTFILESIZE=20000
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'

export PS1='\u@\h:\w$(__dotfiles_git_branch)\$ '

if [ -f "$HOME/.shell_local" ]; then
	source "$HOME/.shell_local"
fi
