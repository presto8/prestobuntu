# prestobuntu

A script to customize Ubuntu to my preferences. Requires Ubuntu 22.04 or newer.

Most steps check whether they have already been applied and skip themselves if
so, but the script is not fully idempotent yet — see "Re-running" below.

- Boot
  - Text instead of graphics
- System
  - Allow sudo without password
  - Make system journal persistent across reboots
  - Focus follows mouse
  - Remap CapsLock to Ctrl
  - Hard-code DNS to 1.1.1.1
  - Disable cups, whoopsie, apt-daily, automatic updates
- Remote access
  - openssh-server, with pre-installed authorized keys
  - tailscale
  - corkscrew (for tunnelling ssh over an http proxy)
- Filesystem
  - Remove empty directories from /home/user
- Install packages
  - tmux, git, exuberant-ctags, ripgrep, fd, nodejs, kitty, syncthing
- Neovim
  - Plugin manager: lazy.nvim (bootstraps itself from `init.lua`)
  - Plugins: which-key, neodev, vim-sensible, vim-sleuth, vim-fugitive,
    vim-commentary, vim-unimpaired, supertab, ale, gruvbox.nvim, vim-airline,
    vim-lastplace, vim-ripgrep, vim-gitgutter, undotree, vim-foldsearch, fzf,
    mru, copilot.vim
- Shell
  - zsh with prezto
- User interface
  - Create Gruvbox dark profile for gnome-terminal and neovim

## Installation

Of course, you should inspect and verify the script before running it (as one
should do before running any arbitrary shell script from the Internet).

### Installation from local file

    nano setup  # inspect and verify the script
    bash setup

### Installation from Internet

    wget https://raw.githubusercontent.com/presto8/prestobuntu/main/setup
    nano setup  # inspect and verify the script
    bash setup

## Re-running

Re-running `bash setup` on an already-provisioned machine currently fails in
`setup_tmux`, which clones its tmux plugins unconditionally; under `set -e` the
"already exists" error aborts the whole run. Remove
`~/.config/tmux/plugins` first, or skip that step, until this is fixed.

Config files (`init.lua`, `gitconfig`, `tmux.conf`, ...) are fetched from
GitHub rather than taken from the local checkout, so editing them next to the
script and re-running will *not* install your edits.
