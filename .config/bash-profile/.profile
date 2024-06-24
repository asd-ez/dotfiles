export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# change locale to en_US
export LANG="en_US.UTF-8"

eval "$(/opt/homebrew/bin/brew shellenv)"

# PYENV_ROOT
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# java
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# asdf
. "$HOME/.asdf/asdf.sh"

# dart & flutter
export PATH=$PATH:"/Users/nikita/fvm/default/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"

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

# mysql
export PATH=${PATH}:/usr/local/mysql-8.4.0-macos14-arm64/bin
