# Omarchy dotfiles

Personal configuration for Omarchy 4 (captured on 4.0.4-1). Install Omarchy first;
this repository supplies user configuration, not the operating system.

The repository follows Omarchy's source layout rather than mirroring a home
directory:

```text
config/       application configuration → ~/.config/
shell/        bashrc and bash_profile → ~/.bashrc and ~/.bash_profile
bin/          personal helpers → ~/.local/bin/
systemd/      user services → ~/.config/systemd/user/
install       preview/install entry point
scripts/      capture, comparison, and desktop activation tools
```

`manifest.json` explicitly maps each repository source to its home-relative
installation destination. Nothing recursively copies your home or `.config`.
Live files remain ordinary files so Omarchy updates and settings changes can
write them normally. Repository files are saved copies, not live symlinks;
capture live changes or install repository edits explicitly.

## Daily workflow

```sh
cd ~/Code/dotfiles
./scripts/dotfiles status                 # exit 1 means configuration drift
./scripts/dotfiles capture                # preview live -> repository
./scripts/dotfiles capture --write        # capture listed files, with backups
git diff
git status --short                      # also review new/untracked files
# git add <reviewed paths>; git commit; git push
```

Capture never commits or pushes. Review contents before publishing: an allowlist
prevents unrelated files being collected, but cannot prevent you from putting a
secret into a managed file. New files must be individually mapped in the manifest.
Missing sources are errors; capture never silently deletes a saved configuration.
`git diff` does not show untracked contents until they are staged.

## Restore or apply repository edits

```sh
./install                               # preview repository -> live
./install --write                        # back up differing files, then copy
./install --write --activate             # also apply preferences/reload desktop
```

The activation script reloads and validates Hyprland, enables/restarts the hot
corner, disables the screensaver and automatic suspend, and enables idle locking
(turns Stay Awake off). Activation requires an active Hyprland session. Plain
`--write` only installs files; use `--activate` to restore these preferences too.
Shell config takes effect in new shells; restart terminals/Neovim to load their
settings. Git and tmux are configured at their XDG paths.

Both write commands save overwritten files, outside the repo, under
`~/.local/state/dotfiles/backups/<timestamp>/<command>/`. Restore any individual
file from there with `cp -a`. Symbolic links are preserved, not dereferenced;
symlinked parent directories are refused for manual review. The copy commands
never delete unrelated destination files or install packages.

To try a restore without affecting the desktop:

```sh
./install --home /tmp/dotfiles-restore --write
./scripts/dotfiles status --home /tmp/dotfiles-restore
python3 -m unittest discover -s tests -v
```

## What is included

- Active Hyprland Lua configuration, Caps Lock as Control, monitor layout,
  night-light and portal settings.
- Omarchy shell/bar: bottom bar, 45-minute idle lock, disabled screensaver.
- Hot-corner script and systemd user service: dwell half a second in the bottom
  left 3 pixels of the leftmost monitor; monitor layout is refreshed automatically.
- Alacritty, Ghostty, Kitty, Foot, Bash, tmux, Starship, Git, mise, and current
  Neovim/LazyVim configuration with its plugin lockfile.
- Omarchy's dynamic Neovim theme symlink. Theme files themselves remain managed
  by Omarchy, as do packaged hooks and default settings under `/usr/share/omarchy`.
  The relative Neovim theme link is intended to resolve at its installed path;
  it may appear broken when browsing the repository.

Screensaver and automatic-suspend preferences are set idempotently through
`omarchy toggle screensaver-off on` and `omarchy toggle suspend-off on` during
activation. No runtime state files are stored in the repository. `status` and
`capture` compare managed files only; they do not capture changes to these
preferences. Edit `scripts/activate-omarchy` to change the restored preferences.
The shell screensaver deadline (2760 seconds) is after the lock deadline (2700),
so the idle service locks first and cancels its pending screensaver timer.

Current appearance is the stock `tokyo-night` theme with `1-quattro.jpg`. On a
fresh machine, use `omarchy theme set tokyo-night`; the packaged theme provides
its background and generated terminal/editor colors. Theme selection remains
an explicit restore step rather than copying generated files.

## Machine-specific and private configuration

- `~/.bashrc.local`: project paths, remote forwarding aliases, service profiles.
  Sourced after the shared Bash settings; preserved locally during migration.
- `~/.config/git/local`: Git identity or machine-specific signing. Included by
  the shared Git config; preserved locally, never captured. On a fresh machine:
  `git config --file ~/.config/git/local user.name 'Your Name'` and likewise
  `user.email`. Configure signing there if desired.
- `config/hypr/monitors.lua` describes this laptop and HDMI display.
  Review it before applying to another machine.
- tmux currently uses an existing `~/Code/tmux-yank` checkout. The config guards
  that optional integration; native OSC 52 forwarding remains configured.
- Bash's optional uv environment script is supplied by uv, not this repo.
- A fresh Omarchy installation supplies the current theme links/state; pick a
  theme through Omarchy if restoring onto an installation without those files.

Credentials, SSH keys, browser profiles, history, application databases,
Omarchy upgrade backups, and generated theme files are excluded from capture.
The pre-existing Git repository inside `~/.config` is left untouched; use this
repo for the workflow above. Old live `.conf` files are not removed by this
migration; the active Lua files are the ones captured here.

This layout migration retains the current Neovim behavior; choosing a smaller
editor setup is a separate configuration change.

See [the migration review](docs/migration.md) for decisions about the old repo.
