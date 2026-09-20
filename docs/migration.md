# Migration review — 2026-09-20

Baseline: legacy repository commit `a52e16c` (`gitconfig`), current Omarchy
4.0.4-1. Every tracked legacy file was also copied into
`~/.local/state/dotfiles/backups/20260920-130403/legacy-repo` before replacement.
The original versions remain in Git history. This migration targets Omarchy;
macOS is not an actively maintained profile.

| Old component | Decision and reason |
| --- | --- |
| `.gitconfig` | Replace with active XDG Git aliases, rebase and branch preferences. Separate identity into private `~/.config/git/local`. The old macOS 1Password signing executable is unusable here; do not enable signing without a configured local key. Old Delta UI preferences were not active and are not imposed. |
| `.zshrc` | Replace with the active Omarchy Bash setup and vi editing. Oh My Zsh, pyenv prompts, and Kubernetes prompt plugins are not part of the current shell. Existing project/host aliases stay in a private local file. |
| `.tmux.conf` | Replace with current XDG tmux settings: mouse, vi mode, window status behavior and OSC 52 clipboard forwarding. Preserve the current prefix; do not revive the old Ctrl-H prefix. Guard the optional local tmux-yank checkout. |
| `Brewfile` | Remove: macOS/Homebrew provisioning is unrelated to the installed Arch/Omarchy baseline. Do not blindly reinstall the old tool inventory. |
| `bin/helix-python-wrapper` | Remove: hardcoded `/Users/james`, Homebrew, pyenv and old project paths. Also logged every invocation to a history file. |
| `requirements.hx.txt` | Remove: frozen 2024 editor environment tied to that obsolete wrapper, not a project dependency specification. |
| Neovim bootstrap, options, keymaps and plugin lockfile | Replace with active LazyVim configuration. Preserve relative-number preference, current diagnostics/navigation keys and remote clipboard setup. |
| Old Python LSP plugin | Remove: explicitly launches three servers through the obsolete macOS wrapper. Do not transplant it into the current plugin configuration. |
| Old Telescope search overrides | Remove: not present in the active editor. Keep current picker behavior. |
| Old Fugitive/RepoLink plugin declarations | Remove with the retired editor profile; these plugins are not in the active configuration. Remove the stale current `g#` mapping too: it called `Ggrep`, which is unavailable without Fugitive. Other current Git/editor bindings are retained. |
| Old disabled-plugin declarations | Remove: do not impose old Noice/dashboard choices on current LazyVim. |
| Old fixed Kanagawa theme | Replace with Omarchy's dynamic theme link and current theme hot-reload support. |
| Starter README and inactive example plugin | Remove from the new managed set; use the repository guide. Preserve the Neovim license. |
| Root `.gitignore` | Extend with local overrides, editor artifacts, environment files and common credential paths. Actual capture scope comes from the explicit manifest. |

Live shell aliases and Git identity were split into private local includes with
backups in `~/.local/state/dotfiles/backups/20260920-130426/shell-git`.
No credentials were intentionally imported. Review all new files before the
first public commit; this is not a historical secret audit of the old repository.

Additional portability cleanup: guard the optional uv shell environment and
tmux-yank checkout; replace invalid string-valued Starship `disabled` settings
(which contained a hardcoded home directory) with boolean `false`.

## Source layout migration

Replaced the initial home-directory mirror with `config/`, `shell/`, `bin/`,
and `systemd/`. The manifest now maps repository sources to installation
destinations. `./install` provides a preview by default and `--write` performs
backed-up copies; `--activate` also reloads the desktop and applies preferences.

Removed the two repository copies of empty screensaver/suspend flag files.
Their preferences are now restored through Omarchy commands during activation.
The live flags were left intact. All 43 remaining managed files retain their
previous contents and installation paths, including the Neovim theme symlink.
The full pre-migration working tree (excluding Git metadata) was backed up to
`~/.local/state/dotfiles/backups/20260920-133955/layout`.
