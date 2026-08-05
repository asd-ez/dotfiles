# 0006. No plugin manager in any managed config

- **Status**: Accepted
- **Date**: 2026-08-05
- **Deciders**: Repo owner
- **Tags**: dependencies, shell, tmux

## Context

The tmux config declared eight plugins through tpm (tmux plugin manager): tpm itself,
tmux-sensible, vim-tmux-navigator, tmux-themepack, tmux-resurrect, tmux-continuum,
tmux-sessionist and the dracula theme, plus their configuration blocks. The last line of the
file ran tpm.

tpm was not installed. It had not been installed on the machine in use, and nothing in the
repo installs it. tmux still started, because a failed `run` directive is not fatal, so the
config had been silently degraded to its built-in settings for an unknown length of time.
oh-my-fish had the same shape, and was removed with fish in
[0004](0004-bash-is-the-only-managed-shell.md).

A plugin manager makes a config file a manifest that some other process has to satisfy.
`chezmoi apply` does not satisfy it. So a fresh machine gets a config declaring capabilities
it does not have, and the gap is silent.

## Decision drivers

- A config should do what it says immediately after `chezmoi apply`, with no second step.
- Silent partial application is worse than an obvious absence, because nothing prompts you to
  fix it.
- The value of most of these plugins was small relative to the dependency.

## Decision

No managed config declares plugins for an external manager. `home/dot_tmux.conf` contains
built-in tmux settings only.

Where a plugin provided something genuinely worth keeping, the equivalent built-in setting is
inlined instead. From tmux-sensible that is `escape-time 0`, which removes the escape-key
delay in vim, and a larger `history-limit`. Both are one line of native config.

All keybindings were kept. Removing a binding is losing a feature, not simplifying.

## Alternatives considered

- **Keep tpm and bootstrap it from a chezmoi `run_once_` script.** Rejected for the value on
  offer: it adds a network dependency to provisioning, and a first-run failure mode, in order
  to restore a status bar theme and session persistence. Worth revisiting if session
  persistence (tmux-resurrect) becomes something actually relied on.
- **Vendor the plugins into the repo.** Rejected: it turns a dotfiles repo into a dependency
  mirror, with updates to track by hand.
- **Keep the plugin lines, document that they need tpm.** Rejected: this is the status quo
  that produced the problem. Documentation does not run.

## Consequences

- **Positive**: `chezmoi apply` produces a tmux that fully works. What the file says is what
  you get.
- **Positive**: the config dropped from 63 lines to 39 with no loss of function, because most
  of the removed lines configured plugins that were never loaded.
- **Negative**: the dracula status bar, session persistence across reboots, and seamless
  vim/tmux pane navigation are gone. The first is cosmetic; the second and third are real
  losses, accepted because they were not actually in effect anyway.
- **Neutral**: nothing prevents installing tpm by hand on a machine. This decision governs
  what the repo manages.

## Links

- Related: [0004](0004-bash-is-the-only-managed-shell.md)
- NFR: [portability](../nfr/portability.md), [startup latency](../nfr/startup-latency.md)
