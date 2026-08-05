# Decisions

> Part of [dotfiles documentation](../README.md) · Status: Living · Updated: 2026-08-05

Append-only. A decision is never rewritten in place: when one is reversed, the new record
supersedes it and the old one stays, marked and pointing forward. The rejected
alternatives are the most expensive knowledge here, because each one is something a
reasonable person will propose again, including you in a year.

| Decision | Status | Summary |
| --- | --- | --- |
| [0001](0001-chezmoi-as-the-provisioner.md) | Accepted | chezmoi renders one source tree into `$HOME`, replacing a one-way copy script |
| [0002](0002-source-tree-under-home.md) | Accepted | The source tree lives under `home/` via `.chezmoiroot`, so repo metadata never reaches `$HOME` |
| [0003](0003-template-not-fork.md) | Accepted | OS differences are templated in one file, never branched per machine |
| [0004](0004-bash-is-the-only-managed-shell.md) | Accepted | bash is the only managed shell; zsh, fish and oh-my-fish were removed |
| [0005](0005-profile-and-bashrc-split.md) | Accepted | `.profile` owns env and aliases, `.bashrc` owns interactive behaviour; they source each other under guards |
| [0006](0006-no-plugin-managers.md) | Accepted | No plugin manager in any managed config; built-in settings only |
| [0007](0007-idempotent-path-construction.md) | Accepted | PATH is built through a helper that skips entries already present |
| [0008](0008-windows-junctions-not-symlinks.md) | Accepted | Windows gets nvim and alacritty only, linked with junctions rather than symlinks |
| [0009](0009-machine-local-escape-hatch.md) | Accepted | One unmanaged file per machine, sourced last, so local overrides never fight the repo |

## Writing a new one

Copy the shape of any existing record: context, decision drivers, decision, alternatives
considered, consequences, links. The alternatives section is not optional. A record that
only says what was chosen is a changelog entry, and the repo already has those.
