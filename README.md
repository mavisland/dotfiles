# dotfiles

Cross-platform dotfiles and bootstrap scripts for Windows, macOS, Ubuntu, and Fedora.

## Layout

- `install.sh` - bootstrap entry point for macOS and Linux
- `install.ps1` - bootstrap entry point for Windows
- `scripts/` - shared bootstrap helpers
- `config/` - tracked application and editor config files
- `platform/` - operating-system-specific setup steps

## Current status

- Git defaults are tracked in `config/git/.gitconfig`.
- Editor defaults are tracked in `config/editor/.editorconfig` and `config/vscode/settings.json`.
- Shell defaults start in `config/shell/.bashrc`.
- Bootstrap entry points now install the core Git, editor, and shell files into the home directory.
- macOS, Ubuntu, and Fedora now have a first-pass package installation layer.
- Windows now tries to install `winget` if it is missing, then falls back to Chocolatey for core package installation.
- Windows also installs common CLI tools such as `curl`, `ripgrep`, and `fd`.
- `micro` is installed on every supported platform for command-line editing.

## Run

- macOS / Linux: `bash install.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File install.ps1`

## Next steps

1. Add Git, shell, editor, and terminal configs.
2. Add OS-specific package install scripts.
3. Add a single bootstrap command per platform.
