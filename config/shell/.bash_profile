# Shared login shell defaults
if [ -f "$HOME/.shell-env" ]; then
  . "$HOME/.shell-env"
fi

if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi