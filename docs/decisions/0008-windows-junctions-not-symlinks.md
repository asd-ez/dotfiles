# 0008. Windows gets nvim and alacritty only, linked with junctions

- **Status**: Accepted
- **Date**: 2026-06-29
- **Deciders**: Repo owner
- **Tags**: portability, windows

## Context

Native Windows cannot use most of this repo. bash and tmux do not apply. What does apply is
nvim and alacritty, both of which run natively on Windows and both of which read their config
from Windows-specific locations rather than from `~/.config`:

- Neovim reads `%LOCALAPPDATA%\nvim`
- Alacritty reads `%APPDATA%\alacritty`

chezmoi renders into `$HOME`, so a plain apply puts the configs where the Windows apps will
not look.

Symlinks are the obvious bridge and the wrong one: on Windows, creating a symlink requires
either administrator rights or Developer Mode. A provisioning step that fails on a default
machine is not provisioning.

## Decision drivers

- The bootstrap has to work on a stock Windows account with no elevation.
- Everything that cannot apply should be excluded explicitly, not left to fail at runtime.

## Decision

Two mechanisms:

- `.chezmoiignore` is templated on `.chezmoi.os` and, on Windows, skips `.bashrc`, `.profile`
  and `.tmux.conf`. What remains is nvim and alacritty.
- `run_onchange_after_windows-app-links.ps1.tmpl` creates **junctions** from the Windows
  application directories to the rendered `~/.config` copies. Junctions work without elevation.

The script's entire body is inside a `{{ if eq .chezmoi.os "windows" }}` guard, so it renders
to zero bytes on other platforms and chezmoi does not execute it. Verified: it renders empty
on Linux.

It is also defensive in both directions, returning early if the source is missing and if the
target already exists, so it never clobbers an existing directory.

## Alternatives considered

- **Symlinks.** Rejected: requires admin or Developer Mode, so it fails on a default account.
- **Directory copies.** Rejected: a copy is a snapshot. The next `chezmoi apply` updates the
  `~/.config` copy and the application keeps reading the stale one, which is a silent
  divergence.
- **Set the apps' config paths through environment variables.** Rejected: it works for nvim
  (`XDG_CONFIG_HOME`) but drags in the rest of the XDG layout, and alacritty's support differs.
  Two mechanisms for two apps is worse than one that covers both.
- **Do not support Windows.** Rejected: nvim and alacritty are genuinely used there, and they
  are the two configs with no shell dependency at all, so the cost is one script.

## Consequences

- **Positive**: one bootstrap command works on Windows with no elevation.
- **Positive**: junctions are live views. An apply updates the config the app reads, with no
  second step.
- **Negative**: junctions are directory-only. A future Windows-relevant config that is a single
  file needs a different mechanism.
- **Negative**: this path is exercised rarely, so it is the most likely thing in the repo to be
  quietly broken. It is listed as unverified in the [docs index](../README.md).

## Links

- Depends on: [0003](0003-template-not-fork.md)
- NFR: [portability](../nfr/portability.md)
