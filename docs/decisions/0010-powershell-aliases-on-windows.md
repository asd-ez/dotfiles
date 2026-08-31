# 0010. PowerShell is a managed shell on Windows, wired through a profile stub

- **Status**: Accepted
- **Date**: 2026-08-31
- **Deciders**: Repo owner
- **Tags**: shell, windows, portability

## Context

[0004](0004-bash-is-the-only-managed-shell.md) made bash the only managed shell and
[0008](0008-windows-junctions-not-symlinks.md) narrowed Windows to nvim and alacritty. The
first real apply on a Windows machine surfaced what those two decisions add up to: no aliases
at all. `ccd`, the git shorthands and `ll` all live in `dot_profile.tmpl`, which
`.chezmoiignore` skips on Windows, so none of them arrived.

The machine had no aliases in any shell. Neither `$PROFILE` path existed, and `$HOME` held no
bash startup files. Git Bash is installed, but it is not what the terminal opens: alacritty on
Windows launches PowerShell by default, and PowerShell is the shell actually in use.

0004's reasoning applies here without modification. Its rule was not "manage bash", it was
*the shell that is actually used should be the shell that is actually managed*. On Windows,
that shell is PowerShell.

## Decision drivers

- Aliases are the most-used part of this repo per day. Their absence is the difference a
  person notices within a minute of opening a terminal.
- Configuration for a shell nobody starts is the liability 0004 deleted zsh and fish for. The
  converse obligation is to manage the shell that is started.
- The bootstrap must keep working without elevation, and must not clobber a PowerShell profile
  that already has content.
- `Documents` is redirected into OneDrive on a large share of Windows installs, so any
  hardcoded profile path is a portability trap.

## Decision

PowerShell joins bash as a managed shell, on Windows only.

- `home/dot_config/powershell/profile.ps1` holds the Windows aliases, mirroring the alias
  block of `dot_profile.tmpl`. `.chezmoiignore` grew an `else` branch so it is skipped on
  every non-Windows OS.
- `run_onchange_after_windows-powershell-profile.ps1.tmpl` writes a one-line stub at
  `$PROFILE.CurrentUserAllHosts` that dot-sources the managed file. It asks PowerShell for
  `$PROFILE` rather than hardcoding `Documents\WindowsPowerShell`, appends its line only when
  absent, and never overwrites an existing profile. Like the junction script, its whole body
  sits inside a `{{ if eq .chezmoi.os "windows" }}` guard and renders to zero bytes elsewhere.
  Verified: it renders empty, and a forced re-run does not append the line twice.

Two PowerShell rules dictate the shape of the alias file, and both are non-obvious:

- `Set-Alias` cannot carry arguments, so every alias with a flag is a function taking `@args`.
  This is exactly what `ccd` and `gcb` need.
- Aliases outrank functions in command resolution, so a built-in alias of the same name wins
  silently. `gc`, `gp` and `gcb` are removed with `-Force` before being redefined; without
  that, `gc` stays `Get-Content` and the function is dead code that looks correct.

## Alternatives considered

- **Un-ignore `.profile` so Git Bash reads the aliases verbatim.** Rejected. Git Bash is
  installed but is not the shell the terminal opens, so this puts the aliases in a shell that
  is not used while leaving the used one bare — 0004's liability restated. It also renders
  `PNPM_HOME` as `$HOME/.local/share/pnpm`, which is the wrong path on Windows.
- **`Set-Alias` for everything.** Rejected: it cannot pass arguments, and arguments are the
  entire content of `ccd` and `gcb`.
- **Manage `Documents\WindowsPowerShell\profile.ps1` directly as a chezmoi file.** Rejected,
  and it is the tempting one because it needs no script and shows up in `chezmoi diff`.
  chezmoi renders relative to `$HOME`, so the source path bakes in `Documents`; on a machine
  where that is redirected into OneDrive the file lands where PowerShell never looks, and the
  failure is silent. Asking PowerShell for `$PROFILE` is the only form that survives
  redirection.
- **Junction it, as nvim and alacritty are bridged.** Rejected: junctions are directory-only
  and `$PROFILE` is a single file. This is precisely the negative 0008 wrote down.
- **One shared alias file for every OS.** Rejected: POSIX and PowerShell syntax do not
  overlap, so the "shared" file would be a template with two disjoint bodies. That is
  [0003](0003-template-not-fork.md)'s per-machine fork wearing a template's clothes.
- **Also manage a pwsh 7 profile.** Rejected: only Windows PowerShell 5.1 is installed here.

## Consequences

- **Positive**: `ccd` and the git shorthands work on Windows, in the shell alacritty opens.
- **Positive**: the stub is one static line, so editing the alias file takes effect in the
  next shell with no re-apply. That is the same live-view property the junctions give the
  application configs.
- **Negative, and the real cost**: the alias list now exists twice, in `dot_profile.tmpl` and
  in `profile.ps1`, in two syntaxes. Nothing enforces agreement, so they will drift. Adding an
  alias means adding it in both places.
- **Negative**: `gc`, `gp` and `gcb` no longer mean `Get-Content`, `Get-ItemProperty` and
  `Get-Clipboard` in an interactive PowerShell. Any PowerShell documentation or answer that
  uses them will misbehave under this profile. The full cmdlet names are unaffected.
- **Negative**: the stub lands in a file chezmoi does not manage, so `chezmoi diff` never
  shows it and removing this feature leaves the line behind by hand.

## Links

- Depends on: [0004](0004-bash-is-the-only-managed-shell.md),
  [0008](0008-windows-junctions-not-symlinks.md)
- Related: [0003](0003-template-not-fork.md)
- NFR: [portability](../nfr/portability.md), [idempotency](../nfr/idempotency.md)
