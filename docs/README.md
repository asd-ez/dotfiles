# dotfiles documentation

> Status: Living · Updated: 2026-08-05

Why this repo is shaped the way it is. The [root README](../README.md) says what the
files are and how to run chezmoi; this tree says why, and what has to stay true.

A dotfiles repo looks trivial until it breaks a login shell on a machine you are
holding at an airport. Most of what is written here exists because something already
went wrong, or would have.

## Layout

| Directory | What lives there |
| --- | --- |
| [decisions/](decisions/README.md) | Architecture decision records. Append-only: a reversed decision is superseded, never rewritten. |
| [nfr/](nfr/README.md) | Non-functional requirements. The properties any change has to preserve. |
| [guides/](guides/README.md) | Task-oriented runbooks: bootstrap a machine, change a dotfile, debug a shell. |

## The shape in one paragraph

One git repo is the single source for every machine. [chezmoi](https://chezmoi.io)
renders it into `$HOME`, resolving per-OS differences through Go templates rather than
per-machine branches ([0001](decisions/0001-chezmoi-as-the-provisioner.md),
[0003](decisions/0003-template-not-fork.md)). The source tree sits under `home/` so
repo metadata never lands in your home directory
([0002](decisions/0002-source-tree-under-home.md)). bash is the only managed shell
([0004](decisions/0004-bash-is-the-only-managed-shell.md)): `.profile` owns environment
and aliases, `.bashrc` owns interactive behaviour, and they source each other under
guards ([0005](decisions/0005-profile-and-bashrc-split.md)). Nothing depends on a plugin
manager ([0006](decisions/0006-no-plugin-managers.md)).

## Reading order

New to the repo, in order: [0001](decisions/0001-chezmoi-as-the-provisioner.md) for the
tool, [0004](decisions/0004-bash-is-the-only-managed-shell.md) for the shell scope,
[0005](decisions/0005-profile-and-bashrc-split.md) for the wiring that actually bites,
then [idempotency](nfr/idempotency.md), which is the requirement most changes threaten.

## Known gaps

- **Nothing is tested automatically.** Every claim in these docs was verified by hand
  once. There is no CI, so a regression surfaces the next time someone opens a shell.
  See [idempotency](nfr/idempotency.md) for the checks worth running by hand.
- **macOS and Windows are designed for, not currently verified.** The templated branches
  for both are written and reviewed but were last exercised on Linux/WSL2 only. Treat a
  first apply on either as unproven.
- **A Claude Code statusline sync was lost.** It was merged (PR #20) into an
  already-merged branch rather than into `master`, so it never reached the default
  branch, and the branch holding it has since been deleted. If that feature is wanted,
  it needs rebuilding.
