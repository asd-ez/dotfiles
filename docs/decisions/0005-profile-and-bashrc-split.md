# 0005. .profile owns environment, .bashrc owns interaction, and they source each other under guards

- **Status**: Accepted
- **Date**: 2026-08-05
- **Deciders**: Repo owner
- **Tags**: shell, correctness

## Context

bash reads different files depending on how it starts, and the rules are not intuitive:

- A **login** shell reads `~/.profile` (absent `~/.bash_profile`) and does **not** read
  `~/.bashrc`.
- A **non-login interactive** shell reads `~/.bashrc` and does **not** read `~/.profile`.

So a definition placed in exactly one file is missing from one of the two cases. Environment
in `.profile` alone is absent from every terminal tab that starts a non-login shell; put it
in `.bashrc` alone and it is absent from anything launched by a login shell that is not
interactive.

The distribution default resolves this in one direction only: Ubuntu's `~/.profile` sources
`~/.bashrc` when running bash. The managed `.profile` originally did not, so applying it
would have cut the chain that reaches `~/.bashrc` at all.

## Decision drivers

- Both shell types must end up with the same environment and aliases. Anything less produces
  bugs that reproduce in one terminal and not another.
- The split has to survive being sourced from either direction, without infinite recursion.
- A future non-bash consumer (a plain `sh` script) should still get environment without
  dragging in prompt and history configuration.

## Decision

Two files with distinct ownership:

- `home/dot_profile.tmpl` owns environment, PATH and aliases. It is POSIX and safe for any
  `sh`.
- `home/dot_bashrc` owns interactive behaviour only: prompt, history, completion.

They source each other, so whichever bash reads first pulls in the other. Recursion is
prevented by a guard variable set at the top of each file: `.profile` sets
`__PROFILE_SOURCED`, `.bashrc` sets `__BASHRC_SOURCED`, and each sources the other only if
the other's flag is unset.

Traced both ways:

- **Login**: `.profile` sets its flag, defines environment, sees `__BASHRC_SOURCED` unset,
  sources `.bashrc`. `.bashrc` sets its flag, sees `__PROFILE_SOURCED` set, does not recurse.
- **Non-login**: `.bashrc` sets its flag, sees `__PROFILE_SOURCED` unset, sources `.profile`.
  `.profile` sets its flag, sees `__BASHRC_SOURCED` set, does not recurse.

## Alternatives considered

- **One file, sourced by the other.** Rejected: whichever file holds everything ends up
  running prompt and history configuration inside non-interactive `sh`, which is both wasteful
  and a source of surprising output in scripts.
- **A single guard variable.** Rejected because it does not terminate. With one flag, the
  non-login path sets it, sources the other file, and that file's own check for the same flag
  cannot distinguish "already loaded" from "loaded by me", so one of the two directions either
  loops or drops its counterpart. Two flags encode direction, which is the actual requirement.
- **Duplicate the environment into both files.** Rejected: two copies of PATH construction
  drift, and the drift is invisible until one shell type behaves differently.
- **Make `.bashrc` a symlink to `.profile`.** Rejected: it merges the two ownerships and
  breaks the `sh` case.

## Consequences

- **Positive**: login and non-login bash reach identical environment and aliases. Verified by
  running both and comparing.
- **Positive**: `.profile` stays POSIX, so a plain `sh -c '. ~/.profile'` is safe.
- **Negative, and it is real**: the guards are the subtlest code in the repo and look like
  cargo cult until you trace both paths. Anyone editing either file has to preserve them.
  This record is the explanation; the comments in the files point here.
- **Negative**: the flags leak into the shell's variable namespace. They are prefixed with a
  double underscore to signal that they are internal.

## Links

- Depends on: [0004](0004-bash-is-the-only-managed-shell.md)
- Related: [0007](0007-idempotent-path-construction.md), [0009](0009-machine-local-escape-hatch.md)
- NFR: [idempotency](../nfr/idempotency.md)
- Guide: [troubleshooting](../guides/troubleshooting.md)
