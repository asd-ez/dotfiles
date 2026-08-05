# Troubleshooting

> Part of [guides](README.md) · Status: Living · Updated: 2026-08-05

Symptoms first. Each entry says how to confirm the cause before changing anything.

## An alias or variable is missing in one shell but not another

The two bash entry paths read different files. Compare them:

```sh
bash -lic 'alias ccd; echo "$PATH"'   # login: .profile first
bash -ic  'alias ccd; echo "$PATH"'   # non-login: .bashrc first
```

If one works and the other does not, the mutual sourcing between `.profile` and `.bashrc` is
broken. Check that both guard variables are set in a live shell:

```sh
bash -lic 'echo "profile=$__PROFILE_SOURCED bashrc=$__BASHRC_SOURCED"'
```

Both should print `1`. See [0005](../decisions/0005-profile-and-bashrc-split.md).

## An alias is defined but the wrong definition wins

`~/.bash_aliases` is sourced last, so it overrides everything managed. That is deliberate
([0009](../decisions/0009-machine-local-escape-hatch.md)), and it is the first place to look
when a managed alias appears not to take effect.

```sh
grep -n 'alias name' ~/.bash_aliases
type name          # what is actually resolving
```

## PATH has duplicate entries

First decide whether it is a live bug or a stale session. A session inherits its PATH from
whatever started it, so duplicates created before a fix persist until you log in again.

```sh
echo "$PATH" | tr : '\n' | sort | uniq -d      # duplicates in THIS session

env -i HOME="$HOME" TERM=xterm PATH=/usr/bin:/bin bash -c '
  for i in 1 2 3; do . "$HOME/.profile" >/dev/null 2>&1; done
  echo "$PATH" | tr : "\n" | sort | uniq -d
'                                              # duplicates the CONFIG creates
```

Output from the first and nothing from the second means the config is correct and the session
is stale. Open a new terminal.

Output from the second is a real bug: a PATH addition bypassed `__path_prepend`. See
[0007](../decisions/0007-idempotent-path-construction.md).

## Every shell prints a setlocale warning

```
bash: warning: setlocale: LC_CTYPE: cannot change locale (en_US.UTF-8)
```

The locale is exported but not generated on the system. Confirm:

```sh
locale -a | grep -i en_US
```

`.profile` guards the export against exactly this, so seeing the warning means either the
guard was removed or something else exports `LANG`. To get the locale itself:

```sh
sudo locale-gen en_US.UTF-8 && sudo update-locale
```

## Opening a shell hangs

Almost certainly infinite recursion between `.profile` and `.bashrc`. Get a shell that reads
neither:

```sh
bash --norc --noprofile
```

Then reproduce it safely with a timeout, in a scratch home:

```sh
SB=$(mktemp -d); cp ~/.profile ~/.bashrc "$SB/"
timeout 10 env -i HOME="$SB" TERM=xterm PATH=/usr/bin:/bin bash -lic 'echo ok'
```

A timeout rather than `ok` confirms it. The cause is a missing or renamed guard variable.

## chezmoi apply does nothing

chezmoi is looking at a different source directory than you think.

```sh
chezmoi source-path      # must be <your repo>/home
chezmoi managed          # must be non-empty
```

An empty `chezmoi managed` means the source directory is not this repo. Fix
`~/.config/chezmoi/chezmoi.toml`, per [bootstrap a machine](bootstrap-a-machine.md).

## A file I deleted from the repo is still in my home directory

Expected. chezmoi does not remove a target when its source disappears; it stops managing it.
Delete the orphan by hand, on every machine. See [change a dotfile](change-a-dotfile.md).

## tmux is missing its theme, or plugins do not load

Also expected. No plugin manager is configured
([0006](../decisions/0006-no-plugin-managers.md)). The config is built-in settings only. If
you want tpm back, install it yourself; the repo will not.

## zsh or fish behaves oddly

Neither is managed ([0004](../decisions/0004-bash-is-the-only-managed-shell.md)). Any zsh or
fish config on a machine is either a leftover from before that change or something you added
by hand. This repo will not update or repair it.
