# dotfiles

Cross-platform dotfiles and bootstrap scripts for Windows, macOS, Ubuntu, and Fedora.

## Layout

- `install.sh` - bootstrap entry point for macOS and Linux
- `install.ps1` - bootstrap entry point for Windows
- `scripts/verify.sh` - verification entry point for macOS and Linux
- `scripts/verify.ps1` - verification entry point for Windows
- `scripts/` - shared bootstrap helpers
- `config/` - tracked application and editor config files
- `platform/` - operating-system-specific setup steps

## Current status

- Git defaults are tracked in `config/git/.gitconfig`.
- Editor defaults are tracked in `config/editor/.editorconfig` and `config/vscode/settings.json`.
- Shell defaults start in `config/shell/.bashrc`.
- Local-only shell overrides can live in `~/.shell_local` and are loaded by bash and zsh.
- `micro` is exported as the default editor through shared shell and PowerShell profiles.
- Shared shell and PowerShell prompts now show the current directory and Git branch.
- Windows Terminal gets a tracked profile defaults file when its settings path is available.
- macOS gets tracked Terminal and iTerm2 preference templates, plus zsh completion helpers.
- macOS shell integration now loads Homebrew completions and zsh plugins when available.
- Linux and macOS package installs now include `stow`, PHP tooling, Composer, and common database clients.
- VS Code settings are installed into each platform's user profile location.
- Windows now installs Laragon, NanaZip, database clients, and Composer when winget is available; Laragon handles PHP, MySQL, Apache, and Nginx.
- Bootstrap entry points now install the core Git, editor, and shell files into the home directory.
- macOS, Ubuntu, and Fedora now have a first-pass package installation layer.
- Windows now tries to install `winget` if it is missing, then falls back to Chocolatey for core package installation.
- Windows also installs common CLI tools such as `curl`, `ripgrep`, and `fd`.
- `micro` is installed on every supported platform for command-line editing.

## Run

- macOS / Linux: `bash install.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File install.ps1`

## Verify

- macOS / Linux: `bash scripts/verify.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`

## Sync

1. Run the verification script for your platform.
2. Test the installer on the current machine.
3. Fix any config drift or missing package IDs.
4. Commit and push the changes.

## Maintenance

1. Keep package IDs and platform defaults aligned with the real machines you use.
2. Re-run verification after any config or installer change.
3. Update the Windows Laragon or NanaZip choices if your workflow changes.
