if status is-interactive
    # Commands to run in interactive sessions can go here
end
bass source ~/.profile

# Created by `pipx` on 2024-02-14 09:38:39
set PATH $PATH /Users/nikita/.local/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# pnpm
set -gx PNPM_HOME "/Users/nikita/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
