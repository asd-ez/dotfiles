export HOMEBREW_CASK_OPTS="--appdir=/Applications"

eval "$(/opt/homebrew/bin/brew shellenv)"

# Setting PATH for Python 3.10
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:${PATH}"
export PATH

# PYENV_ROOT
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# java
# echo 'export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"'
# export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# node versions
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# rbenv
eval "$(rbenv init - zsh)"

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

# custom functions
function _sys_notify() {
  local notification_command="display notification \"$2\" with title \"$1\""
  osascript -e "$notification_command"
}
alias sys-notify="_sys_notify $1 $2"
