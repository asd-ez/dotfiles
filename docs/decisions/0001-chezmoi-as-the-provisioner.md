# 0001. chezmoi renders one source tree into $HOME

- **Status**: Accepted
- **Date**: 2026-06-29
- **Deciders**: Repo owner
- **Tags**: tooling, portability

## Context

The repo previously carried a `cp.sh` script that copied files from `$HOME` into the repo.
That is a backup, not a provisioner: it moves information in one direction only. Setting up
a new machine meant copying files back by hand and then editing every hardcoded macOS path
inside them.

Three properties were missing. There was no way to preview what a change would do before it
touched a live home directory. There was no way to express "this line only on macOS" except
by keeping divergent copies. And there was no record of which files were even supposed to be
managed, so a file that stopped being copied simply disappeared from the set silently.

## Decision drivers

- A new machine has to be reachable from one command, because that is the moment the repo
  earns its keep and also the moment nobody wants to debug shell config.
- Changes to a login shell are high blast radius. A preview step is not a nicety.
- The set of managed files must be explicit and enumerable, not implied by a script's
  arguments.

## Decision

[chezmoi](https://chezmoi.io) is the provisioner. The repo is a chezmoi source tree; the
target is `$HOME`. `chezmoi diff` previews, `chezmoi apply` writes, `chezmoi managed`
enumerates. `cp.sh` was deleted.

Source files carry their target in the filename (`dot_profile.tmpl` becomes `~/.profile`),
so the mapping is visible in a directory listing rather than encoded in a script.

## Alternatives considered

- **GNU Stow, or hand-rolled symlinks.** Rejected: symlink farms have no templating, so
  per-OS differences come back as forked files. They also expose the repo through `$HOME`,
  which is what [0002](0002-source-tree-under-home.md) exists to avoid. Windows makes it
  worse, since symlinks there need elevation.
- **A bare git repo checked out over `$HOME`.** Rejected: every stray file in the home
  directory becomes repo-adjacent noise, and `git status` in `$HOME` is permanently dirty.
  There is no preview step and no templating.
- **An Ansible playbook.** Rejected as disproportionate. It solves machine provisioning,
  of which dotfiles are a small part, and it costs a runtime plus a dependency tree to
  render a dozen text files.
- **Keep `cp.sh`, add per-OS subdirectories.** Rejected: this is the fork model that
  [0003](0003-template-not-fork.md) rejects on its own merits.

## Consequences

- **Positive**: `chezmoi diff` before `chezmoi apply` makes every change reviewable, which
  matters most for the files that decide whether a shell starts at all.
- **Positive**: the managed set is queryable. `chezmoi managed` is how you find out what a
  fresh apply would touch, which is exactly what you want to know before running one.
- **Negative**: a real dependency. A machine without chezmoi cannot apply the repo, and
  chezmoi itself lives in a user-local bin directory that the managed `.profile` puts on
  PATH. That ordering is circular on a truly fresh machine, so the bootstrap installs
  chezmoi first. See [bootstrap a machine](../guides/bootstrap-a-machine.md).
- **Negative**: filenames are no longer the names of the files they become. `dot_profile.tmpl`
  is not greppable as `.profile`.
- **Neutral**: removing a source file does not remove its target. Deletion is a two-step
  operation, documented in [change a dotfile](../guides/change-a-dotfile.md).

## Links

- NFR: [portability](../nfr/portability.md), [recoverability](../nfr/recoverability.md)
- Follow-on: [0002](0002-source-tree-under-home.md), [0003](0003-template-not-fork.md)
