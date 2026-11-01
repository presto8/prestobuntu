# Auto-attach to a multiplexer on interactive SSH logins.
#
# Source this at the very top of .zshrc, before the powerlevel10k instant
# prompt: instant prompt redirects the tty, and attaching after that can fail.
#
# The multiplexer is chosen by $AUTOATTACH (tmux | corgi | herdr), which can
# be set in the environment or persisted in ~/.config/zsh/autoattach.conf.
# If the chosen one is not installed, this script just gets out of the way
# and gives a plain zsh.
#
# Skips when:
# - already inside a corgi pane ($CORGI_PANE set) or tmux ($TMUX set)
# - the shell is not a login shell: `ssh <host> zsh` (and any ssh command
#   form) runs a non-login shell and gets a plain zsh instead
#
# Detach behavior: corgi and herdr use prefix q / prefix d; tmux uses prefix
# d. The daemon (or the session) keeps running on the host; reconnect with
# plain ssh.

if [[ -z $TMUX && -z $CORGI_PANE && -n $SSH_TTY && -o login && -t 0 && -t 1 ]]; then

    # Resolve the choice: AUTOATTACH env var, then autoattach.conf, then
    # whichever is actually installed.
    local conf
    conf="${ZDOTDIR:-$HOME}/autoattach.conf"
    local attach="${AUTOATTACH:-}"
    if [[ -z $attach && -r $conf ]]; then
        source "$conf"
        attach="${AUTOATTACH:-}"
    fi
    if [[ -n $attach ]]; then
        attach="${attach:l}"
    fi

    case $attach in
        tmux)
            # Each login gets its own session grouped with "prezto" (shared
            # windows, independent current window) that is destroyed on
            # detach; "prezto" itself persists.
            if (( $+commands[tmux] )); then
                tmux has-session -t prezto 2>/dev/null || tmux new-session -d -s prezto
                exec tmux new-session -t prezto \; set-option destroy-unattached on
            fi
            ;;
        herdr)
            if (( $+commands[herdr] )); then
                exec herdr attach
            fi
            ;;
        corgi|'')
            if [[ -x $HOME/.local/bin/corgi ]]; then
                # Absolute path: ~/.local/bin is not on PATH in a fresh SSH
                # login (prestobuntu.zsh adds it later, after this guard runs).
                exec $HOME/.local/bin/corgi
            fi
            ;;
        *)
            echo "autoattach: unknown AUTOATTACH value '$attach' (want tmux, corgi or herdr)" >&2
            ;;
    esac
fi
