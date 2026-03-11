# Return if requirements are not found.
if (( ! $+commands[tmux] )); then
  return
fi

function _zsh_tmux_plugin_run() {
    local _tmux_session="prezto"

    if tmux has-session -t "$_tmux_session" &>/dev/null; then
      tmux new-session -t "$_tmux_session"
    else
      tmux new-session -s "$_tmux_session"
    fi
}

export NO_AUTO_TMUX=1 # disable auto tmux connection in sub-shells
_zsh_tmux_plugin_run
