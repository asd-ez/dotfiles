# 0002. The source tree lives under home/, via .chezmoiroot

- **Status**: Accepted
- **Date**: 2026-06-29
- **Deciders**: Repo owner
- **Tags**: tooling, layout

## Context

By default chezmoi treats the repository root as the source tree. Everything at the root is
then a candidate target: `README.md` would want to become `~/README.md`, and repo-only files
have to be excluded one at a time through `.chezmoiignore`.

That inverts the burden. The exclusion list has to be maintained forever, and forgetting an
entry means a repo file silently lands in a home directory.

## Decision drivers

- Repository documentation and CI config are not dotfiles and should never be candidates.
- The exclusion list should describe genuine per-OS choices, not repo housekeeping.
- Someone reading the repo should be able to tell at a glance which files become dotfiles.

## Decision

`.chezmoiroot` contains `home`. The source tree is `home/`; everything outside it is repo
furniture and is never a target.

`.chezmoiignore` is therefore free to mean one thing only: which managed files a given OS
should skip. Today it carries the Windows block and nothing else.

## Alternatives considered

- **Root as source, exclusions in `.chezmoiignore`.** Rejected: it makes the ignore file
  serve two unrelated purposes, and it fails open. A forgotten entry writes a file to
  `$HOME` rather than refusing.
- **A separate repo for docs.** Rejected: the rationale for a config belongs next to the
  config, and splitting them guarantees the docs rot first.

## Consequences

- **Positive**: adding documentation, CI or scripts to this repo carries no risk of
  provisioning them onto a machine.
- **Positive**: `home/` is a readable manifest of the managed set.
- **Negative**: one more indirection to explain, and paths in chezmoi's own output are
  relative to `home/`, not the repo root, which reads as an inconsistency the first time.
- **Negative**: `chezmoi` invoked without the repo's config will not find the source tree.
  The source directory is set per machine in chezmoi's own config file.

## Links

- Depends on: [0001](0001-chezmoi-as-the-provisioner.md)
- Guide: [change a dotfile](../guides/change-a-dotfile.md)
