# Maintaining these dotfiles

This public repo targets the current Omarchy desktop. Read README.md and
manifest.json before making changes. Use the Omarchy skill for live desktop
configuration and keep /usr/share/omarchy read-only.

- `config/`, `shell/`, `bin/`, and `systemd/` contain source files.
  `manifest.json` maps each source to its home-relative install destination.
- Use `./install` to preview, `./install --write` to install, and add
  `--activate` only to apply preferences and reload the active desktop.
- Store Omarchy toggle preferences as commands in scripts/activate-omarchy,
  not as checked-in runtime flag files.
- Compare `scripts/dotfiles status` before editing; live files may have newer
  user changes. Capture them before editing their repository counterpart.
- Capture/apply preview by default; `--write` makes backed-up file copies.
- After authorized desktop changes, capture the affected configuration and
  verify the repo and live settings agree. Do not commit or push automatically.
- Do not recursively import ~/.config, ~/.local/state, or the home directory.
- Never capture ~/.bashrc.local or ~/.config/git/local; those hold private
  machine/project settings. Inspect every new manifest entry before adding it.
- Preserve Omarchy's dynamic theme links and exclude generated theme contents.
- Do not revive obsolete macOS configs or legacy Hyprland .conf files.
- Test changes to the copy tool with `python3 -m unittest discover -s tests -v`.
- Validate changed Hyprland settings with `hyprctl reload` and
  `hyprctl configerrors`. Avoid invoking the lock merely to test the hot corner.
