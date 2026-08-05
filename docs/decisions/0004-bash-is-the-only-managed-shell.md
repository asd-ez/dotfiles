# 0004. bash is the only managed shell

- **Status**: Accepted
- **Date**: 2026-08-05
- **Deciders**: Repo owner
- **Tags**: shell, scope

## Context

The repo managed three shells: bash indirectly, zsh through oh-my-zsh and powerlevel10k, and
fish through oh-my-fish. Auditing them against the machine actually in use found that none of
the zsh or fish stack was installed, and that each carried a defect.

The zsh config never sourced `~/.profile`, so the shared aliases had never once loaded in zsh.
It also sourced `$ZSH/oh-my-zsh.sh` unconditionally, which errors on any machine without
oh-my-zsh installed.

The fish stack was stranger. oh-my-fish's bundle listed exactly one package, `bass`, whose
sole function is to let fish evaluate POSIX shell scripts. It existed so that fish could read
`~/.profile`, the file holding all the shared configuration. The entire fish and oh-my-fish
layer was a shim compensating for fish not being POSIX.

Meanwhile bash, the actual login shell, was not managed at all. Its `~/.bashrc` was the
distribution default plus hand-edits that existed on one machine and in no repo.

## Decision drivers

- Managed config that is not installed anywhere is not configuration, it is a liability that
  reads as working.
- The shell that is actually used should be the shell that is actually managed.
- Every additional shell multiplies the wiring surface, and the wiring is where the bugs were.

## Decision

bash is the only managed shell. `dot_zshrc.tmpl`, `dot_config/fish/` and `dot_config/omf/`
were deleted, along with the orphaned `~/.zshrc` target. A managed `dot_bashrc` was added,
carrying forward the hand-edits that had only ever existed locally.

## Alternatives considered

- **Keep zsh, fix its `.profile` sourcing.** Rejected on scope, not on merit. The fix is
  three lines and was in fact written before this decision, but maintaining a shell nobody
  starts means its breakage is discovered by accident.
- **Keep fish, drop only oh-my-fish.** Rejected: `bass` was the only package oh-my-fish
  provided, and dropping it takes fish's access to `~/.profile` with it. The layers stand or
  fall together.
- **Manage all three properly.** Rejected: three shells is three wiring problems, and the
  wiring guards in [0005](0005-profile-and-bashrc-split.md) are the subtlest thing in the repo.

## Consequences

- **Positive**: the managed set now matches the used set. Nothing here is theoretical.
- **Positive**: one shell means one place for the login and non-login distinction to be right.
- **Negative**: switching to zsh later means rebuilding its config, and this record is the
  only remaining trace of what it contained.
- **Negative, and the real cost**: the fish config was the sole source of `pnpm`, `bun` and the
  user-local bin directory on PATH, and none of it was written down anywhere else. Deleting
  fish would have silently removed the directory holding the chezmoi binary. Those exports
  were migrated to `home/dot_profile.tmpl`. The general lesson: before deleting a config,
  check what only it provides.
- **Neutral**: `zsh` remains installed as a system package. This decision is about what the
  repo manages, not what is on the machine.

## Links

- Follow-on: [0005](0005-profile-and-bashrc-split.md), [0006](0006-no-plugin-managers.md)
- NFR: [startup latency](../nfr/startup-latency.md)
