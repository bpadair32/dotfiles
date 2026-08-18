# Point zsh at its XDG config directory. Everything else lives in
# $ZDOTDIR/.zshrc; keep this file minimal since it is sourced by every
# zsh invocation, including non-interactive scripts.
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
