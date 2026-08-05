# NFR: Idempotency

> Part of [dotfiles documentation](../README.md) · Status: Built · Verified: 2026-08-05

Doing it twice must be indistinguishable from doing it once. This applies at two levels:
`chezmoi apply` against a machine, and a shell file being sourced more than once in a session.

The second is the one that bites. Shell config is not read once per session; it is read again
by every nested shell, every tmux pane, and anything that re-execs a login shell.

## Requirements

1. **Sourcing `~/.profile` twice produces the same environment as sourcing it once.** Every
   PATH addition goes through `__path_prepend`, which skips entries already present
   ([0007](../decisions/0007-idempotent-path-construction.md)). Before this existed, one entry
   appeared twice at the first nesting level, three times at the second and four at the third,
   growing without bound.

2. **`.profile` and `.bashrc` sourcing each other terminates.** Two guard variables,
   `__PROFILE_SOURCED` and `__BASHRC_SOURCED`, encode direction so that neither path recurses
   ([0005](../decisions/0005-profile-and-bashrc-split.md)). A single shared flag does not
   terminate in both directions.

3. **`chezmoi apply` on an already-applied machine is a no-op.** `chezmoi status` returns
   empty. This is chezmoi's own guarantee; the requirement here is not to undermine it, which
   mainly means not writing scripts that mutate state on every run.

4. **A `run_onchange_` script is safe to re-run.** The Windows junction script returns early
   if the target already exists rather than replacing it, so a re-run cannot clobber a
   directory.

5. **An environment variable set from a value that includes itself must be guarded.** This is
   the general form of requirement 1, and it applies to anything list-shaped, not only PATH.

## How to check

The pristine-environment test is the one that matters, because it isolates the config from
whatever the current session already has:

```sh
env -i HOME="$HOME" TERM=xterm PATH=/usr/bin:/bin bash -c '
  for i in 1 2 3; do . "$HOME/.profile" >/dev/null 2>&1; done
  echo "$PATH" | tr : "\n" | sort | uniq -d
'
# Any output is a duplicate, and a bug.
```

Both shell entry paths, which must agree:

```sh
bash -lic 'echo "$PATH"'   # login: reads .profile, which pulls in .bashrc
bash -ic  'echo "$PATH"'   # non-login: reads .bashrc, which pulls in .profile
```

## Known gaps

- **Pre-existing duplicates are not removed.** The helper prevents new duplicates; it does not
  clean a PATH that already contained them, for instance one inherited from a process started
  before a fix landed. Those persist for that session's lifetime and vanish on a fresh login.
  This looks exactly like a live bug and is not one. Confirm with the pristine test above
  before investigating.
- Nothing runs these checks automatically. They are manual, and they are the checks worth
  running after any change to `home/dot_profile.tmpl`.
