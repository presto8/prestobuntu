# Auto-attach tmux on interactive SSH logins.
#
# Source this at the very top of .zshrc, before the powerlevel10k instant
# prompt: instant prompt redirects the tty, and starting tmux after that fails
# with "open terminal failed: not a terminal".
#
# Each login gets its own session grouped with "prezto" (shared windows,
# independent current window) that is destroyed on detach; "prezto" itself
# persists. Skip it with: ssh -t <host> zsh
if [[ -z $TMUX && -n $SSH_TTY && -o login && -t 0 && -t 1 ]] && (( $+commands[tmux] )); then
  tmux has-session -t prezto 2>/dev/null || tmux new-session -d -s prezto
  exec tmux new-session -t prezto \; set-option destroy-unattached on
fi
