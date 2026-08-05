# 0003. OS differences are templated in one file, never forked per machine

- **Status**: Accepted
- **Date**: 2026-06-29
- **Deciders**: Repo owner
- **Tags**: portability, layout

## Context

The same config has to work on macOS, Linux, WSL2 and native Windows. The differences are
real and unavoidable: Homebrew lives at `/opt/homebrew` on Apple Silicon and
`/home/linuxbrew/.linuxbrew` on Linux. Clipboard access is `pbcopy`, `wl-copy`, `xclip` or
`clip.exe` depending on where you are. Alacritty accepts window keys on macOS that fail to
parse elsewhere.

The obvious structure is one directory or branch per machine. It is also the structure that
guarantees drift: a fix applied on the machine you are sitting at does not reach the other
three, and you find out months later on the machine you use least.

## Decision drivers

- A fix should land once and reach every machine.
- Divergence between machines should be visible in a diff, not discovered at a prompt.
- The set of OS-specific behaviour should be enumerable by grepping for the conditionals.

## Decision

One file per config, with OS differences expressed as chezmoi Go template conditionals on
`.chezmoi.os`. Wholesale exclusions (the files native Windows cannot use at all) go in
`.chezmoiignore`, which is itself templated on the same variable.

Runtime capability differences that are not OS-wide are detected at runtime instead. The
clipboard alias probes for `wl-copy`, then `xclip`, then `clip.exe`, because a Linux machine
may be Wayland, X11 or WSL2 and the OS name does not distinguish them.

## Alternatives considered

- **A branch or directory per machine.** Rejected: it makes divergence the default and
  convergence a manual chore. This is the failure mode the decision exists to prevent.
- **One file per OS, selected by a symlink at apply time.** Rejected: it is the fork model
  with extra steps. The files still drift; only the selection is automated.
- **Detect everything at runtime, no templating.** Rejected in part, adopted in part. It is
  right for clipboard tooling and locale, where the OS name genuinely does not answer the
  question. It is wrong for lines that would be dead weight everywhere else, and it puts
  probe cost into every shell start ([startup latency](../nfr/startup-latency.md)).

## Consequences

- **Positive**: a change lands once. Reviewing a template shows every platform's behaviour
  side by side, which is also how you notice that a platform was forgotten.
- **Negative**: the source files are less readable than what they render to, and a template
  error is only visible after rendering. `chezmoi execute-template` against a source file is
  the cheap way to see the real output.
- **Negative**: templates can only branch on what chezmoi knows at render time. Anything
  that depends on what is installed has to be a runtime conditional in the rendered shell
  code instead, which is a different mechanism that looks similar.

## Links

- Depends on: [0001](0001-chezmoi-as-the-provisioner.md)
- NFR: [portability](../nfr/portability.md)
- Related: [0008](0008-windows-junctions-not-symlinks.md)
