# 0007. PATH is built through a helper that skips entries already present

- **Status**: Accepted
- **Date**: 2026-08-05
- **Deciders**: Repo owner
- **Tags**: shell, correctness, idempotency

## Context

`~/.profile` adds several directories to PATH: a user-local bin, bun, pnpm, pyenv, a Go bin
directory, and Homebrew's paths on macOS. Each was written the obvious way:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

That line is not idempotent, and `~/.profile` is not read once. It is read again by every
nested shell: a shell started inside a shell, every tmux pane, anything that re-execs a login
shell. Each level prepends another copy.

Measured on a live machine, one entry appeared twice at the first nesting level, three times
at the second, four at the third. It grows linearly and without bound for as long as a session
stays open.

The cost is not only cosmetic. Every `command -v` and every command dispatch walks the list,
and a PATH with dozens of duplicate entries makes debugging shadowed binaries considerably
harder. One entry, `PNPM_HOME`, had been written with a guard and was correct; the others had
not, which is exactly how this goes unnoticed.

## Decision drivers

- Sourcing the environment twice must be a no-op. Anything else makes nesting unsafe.
- The guard has to be POSIX, since `.profile` is POSIX by
  [0005](0005-profile-and-bashrc-split.md).
- It should be hard to add a new PATH entry the wrong way.

## Decision

One helper, defined near the top of `home/dot_profile.tmpl`, and every PATH addition goes
through it:

```sh
__path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}
```

The colon padding on both sides is what makes the substring test exact, so `/usr/bin` does
not match `/usr/bin/local`. `PATH` is exported once after the additions rather than on each
line.

This covers the pyenv and Homebrew libiconv lines too, which had the same latent defect on
macOS but had never been observed because that machine was not in use.

## Alternatives considered

- **Deduplicate PATH once at the end.** Rejected: it repairs the symptom after building a
  wrong value, and any correct implementation has to decide which duplicate to keep, since
  order is significant.
- **Guard each line inline with its own `case`.** Rejected: this is what `PNPM_HOME` did.
  It works, and it is exactly the pattern that gets forgotten on the next entry added.
- **Set PATH once, absolutely, rather than prepending.** Rejected: it would discard whatever
  the system profile and the OS put there, which differs per platform.
- **Guard `.profile` so it only ever runs once per session.** Rejected: a nested login shell
  legitimately needs the environment. The requirement is that running it twice is harmless,
  not that it runs once.

## Consequences

- **Positive**: sourcing `.profile` any number of times yields one copy of each entry.
  Verified by sourcing it three times in a pristine environment.
- **Positive**: adding a PATH entry now has an obvious correct form to copy.
- **Negative**: the helper leaks a function into the shell namespace, named with a leading
  double underscore to mark it internal.
- **Negative**: it does not remove duplicates that were already in PATH when `.profile` ran,
  for instance ones inherited from a parent process started before a fix. Those persist for
  the life of that session and disappear on a fresh login. This caused real confusion once,
  and is worth remembering before diagnosing a duplicate as a live bug.
- **Neutral**: `eval "$(brew shellenv)"` on macOS is Homebrew's own output and is not routed
  through the helper.

## Links

- Depends on: [0005](0005-profile-and-bashrc-split.md)
- NFR: [idempotency](../nfr/idempotency.md), [startup latency](../nfr/startup-latency.md)
- Guide: [troubleshooting](../guides/troubleshooting.md)
