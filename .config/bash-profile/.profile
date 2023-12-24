export HOMEBREW_CASK_OPTS="--appdir=/Applications"

eval "$(/opt/homebrew/bin/brew shellenv)"

# PYENV_ROOT
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# java
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# rbenv
eval "$(rbenv init - zsh)"

# asdf
. "$HOME/.asdf/asdf.sh"

# aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias g='git'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'

alias pwdc='pwd | pbcopy'

export PATH="/opt/homebrew/opt/libiconv/bin:$PATH"

# expertbox
export DISABLE_SPRING=true
