# CLAUDE.md

Guidance for working in this repo.

## What this is

`prestobuntu` is a personal Ubuntu provisioning system: a single idempotent Bash
script (`setup`) plus a set of dotfiles it deploys. Running `setup` customizes a
fresh Ubuntu install to the author's preferences. It is safe to re-run — every
step guards against reapplying changes.

Target: Ubuntu 22.04+ (`check_ubuntu_version` hard-fails below 22).

## Layout

- `setup` — the provisioner. All logic lives here. Bash, `set -Eeu -o pipefail`.
- `README.md` — user-facing feature summary + install instructions.
- Dotfiles fetched/deployed by `setup` (each has a corresponding `get_prestobuntu_file` call):
  - `gitconfig` → `~/.gitconfig`
  - `prestobuntu.zsh` → `$XDG_CONFIG_HOME/zsh/prestobuntu.zsh` (aliases, completion, history, ssh-agent fix)
  - `p10k.zsh` → powerlevel10k prompt (generated; do not hand-edit)
  - `zpreztorc` → prezto config
  - `tmux-new-session.plugin.zsh` → prezto contrib plugin (auto-attaches to `prezto` session)
  - `tmux.conf` → `$XDG_CONFIG_HOME/tmux/tmux.conf` (prefix `C-a`, vi mode, tpm plugins)
  - `init.lua` → `~/.config/nvim/init.lua` (lazy.nvim plugin manager)
  - `ssh-agent.service` → user systemd unit for ssh-agent
  - `startup-terminal.desktop` → GNOME autostart (deployed by `auto_start_terminal`, currently not called from `main`)

## How `setup` is structured

- `main()` runs `user_config` first, then dispatches by `INSTALL_MODE`
  (`user`, `system`, or `user,system`). The script refuses to run until the user
  edits `user_config()` to set `INSTALL_MODE`.
- `main()` is the source of truth for what actually runs. Functions defined in
  the file but not called from `main` (e.g. `auto_start_terminal`,
  `disable_if_installed`) are dormant.
- Two dispatch blocks: `*system*` (root-level config: grub, DNS, services,
  journald, tailscale) and `*user*` (dotfiles, packages, zsh/tmux/nvim, per-user
  settings).

## Conventions when editing `setup`

- **Idempotency is mandatory.** Every new step must detect its own prior
  application and no-op on re-run. Use the existing helpers:
  - `install_package` / `remove_package` — check `dpkg -s` before acting.
  - `_require_line "$line" "$file"` — append a line only if absent (fixed-string, line-regexp match).
  - `_sed from to file` — in-place sed with `.bak` backup via sudo.
  - `disable_service` — only disables if currently enabled.
- **Adding a step:** write the function, then wire it into the correct
  (`user` vs `system`) block in `main()`. A function alone does nothing.
- **Deploying a new dotfile:** add the file to the repo, then call
  `get_prestobuntu_file "<name>" "<dest>"` from the relevant setup function. It
  fetches from `raw.githubusercontent.com/presto8/prestobuntu/master`.
- **Privilege model:** never invoke as root; `check_not_root` enforces this.
  Use `sudo`/`sudo -E` inside functions (`-E` preserves `http_proxy`).
- **Output:** `info` (cyan) for progress, `die` (red) to abort. `mute cmd` to silence.
- Network fetches force IPv4 (`curl -4`) — IPv6 is broken on some target hosts.

## Verification

There is no test suite.

- `bash -n setup` — syntax check.
- Prefer `shellcheck setup` if available for static analysis.
- Real behavioral verification requires an Ubuntu 22.04+ VM/container; running
  `setup` on the dev workstation is not meaningful (and `check_ubuntu_version`
  will reject non-Ubuntu).
- When changing a helper like `_require_line`/`_sed`, reason about idempotency
  explicitly — re-running must be a no-op.

## Gotchas

- `p10k.zsh` is machine-generated powerlevel10k config; regenerate via
  `p10k configure`, don't edit by hand.
- Hardcoded versions/URLs exist (e.g. ripgrep 11.0.2 amd64 `.deb`, greenclip
  v4.2). These are `amd64`-only and will fail on arm64 targets.
- `setup_zsh_with_prezto` bails early if `~/.zshenv` or the prezto dir already
  exists, so zsh re-provisioning is all-or-nothing.
