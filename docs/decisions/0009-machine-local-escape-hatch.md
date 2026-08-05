# 0009. One unmanaged file per machine, sourced last

- **Status**: Accepted
- **Date**: 2026-08-05
- **Deciders**: Repo owner
- **Tags**: shell, layout

## Context

Some configuration is genuinely machine-specific and does not belong in a repo shared across
machines: a work-only environment variable, a path to a client checkout, a credential helper
for one context.

Without a sanctioned place for it, it goes into a managed file. That has two failure modes.
The edit is either committed, and now every machine carries one machine's specifics, or it is
left uncommitted, and the next `chezmoi apply` silently overwrites it.

This repo had already been bitten by the second variant. The live `~/.bashrc` carried
`GOPRIVATE` and a Go bin directory that existed in no version of the repo. They were found
only because the file was read before being replaced.

## Decision drivers

- Local additions must survive `chezmoi apply`.
- The boundary between shared and local should be a file path, not a convention someone has
  to remember.
- A local override should win, because that is what override means.

## Decision

`~/.bash_aliases` is the machine-local escape hatch. It is not managed by chezmoi, is never
committed, and `home/dot_bashrc` sources it if it exists:

```sh
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```

It is sourced **last**, after the managed environment and aliases, so anything it defines wins.
The name is the distribution's own convention, which means it is already the file a
Debian-derived system expects for exactly this purpose.

## Alternatives considered

- **No escape hatch; everything goes in the repo.** Rejected: it forces genuinely private or
  machine-specific values into a shared, public repo. See [secrets](../nfr/secrets.md).
- **Templated per-hostname blocks in `.profile`.** Rejected: chezmoi can do this, but it puts
  one machine's specifics in front of every other machine's reader, and the conditionals
  accumulate.
- **Source it first, so managed config wins.** Rejected: it makes the local file unable to
  override anything, which removes the point. A machine-local file that cannot win is a
  machine-local file nobody uses.
- **A `~/.config/dotfiles-local/` directory of fragments.** Rejected as over-built for the
  volume of local configuration involved. One file is enough until it is not.

## Consequences

- **Positive**: local edits survive apply, and the boundary is unambiguous.
- **Positive**: it doubles as a safety net. If a managed change breaks something, the local
  file can override it without touching the repo.
- **Negative**: last-wins means a local definition silently shadows a managed one. When a
  managed alias appears not to take effect, this file is the first place to look, which is why
  [troubleshooting](../guides/troubleshooting.md) says so.
- **Negative**: nothing backs it up. It is unmanaged by design, which also means it is
  unreplicated, and it is lost with the machine.

## Links

- Depends on: [0005](0005-profile-and-bashrc-split.md)
- NFR: [recoverability](../nfr/recoverability.md), [secrets](../nfr/secrets.md)
