eval "$(starship init zsh)"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
alias ls='ls --color=auto'
source <(fzf --zsh)
export FZF_CTRL_R_OPTS="
 --tmux"
eval "$(conda "shell.$(basename "${SHELL}")" hook)"

. "$HOME/.local/bin/env"
