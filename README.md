# dotfiles

Cross-OS dotfiles managed with [chezmoi](https://chezmoi.io). One source repo,
`chezmoi apply` on any machine. OS differences (macOS / Linux / WSL2 / Windows)
are handled with templates rather than per-machine forks.

## Bootstrap a new machine

Install chezmoi and apply this repo in one command:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply asd-ez/dotfiles
```

On Windows (PowerShell):

```powershell
(irm -useb get.chezmoi.io/ps1) | powershell -c -
chezmoi init --apply asd-ez/dotfiles
```

## Day-to-day

```sh
chezmoi edit ~/.bashrc     # edit a tracked file (opens the source template)
chezmoi add ~/.newrc       # start tracking a new file
chezmoi diff               # preview what apply would change
chezmoi apply              # apply the source to this machine
chezmoi update             # git pull + apply in one step
chezmoi cd                 # drop into the source repo to commit/push
```

Edits live in the source repo, then commit and push from `chezmoi cd`.

## Layout

The chezmoi source tree is under `home/` (set via `.chezmoiroot`):

| Source | Target | Notes |
|---|---|---|
| `home/dot_profile.tmpl` | `~/.profile` | env + aliases; brew/clipboard/pnpm templated per OS |
| `home/dot_bashrc` | `~/.bashrc` | interactive bash only (prompt, history, completion) |
| `home/dot_tmux.conf` | `~/.tmux.conf` | built-in settings only, no plugin manager |
| `home/dot_config/nvim/` | `~/.config/nvim/` | LazyVim config |
| `home/dot_config/alacritty/alacritty.toml.tmpl` | `~/.config/alacritty/alacritty.toml` | macOS-only window keys templated |

## Shell wiring

bash is the only managed shell. `~/.profile` holds environment and aliases;
`~/.bashrc` holds interactive behaviour. They source each other so both login
and non-login shells get the full set, guarded by `__PROFILE_SOURCED` /
`__BASHRC_SOURCED` to avoid a loop. PATH entries go through `__path_prepend`
so nested shells don't grow it. Machine-local, unmanaged aliases belong in
`~/.bash_aliases`, which is sourced last and therefore wins.

## OS coverage

- **Linux / WSL2 / macOS**: everything above. WSL2 is treated as Linux.
- **Native Windows**: only **nvim** and **alacritty** (bash and tmux don't
  apply). Everything else is skipped via `.chezmoiignore`.
  `run_onchange_after_windows-app-links.ps1` junctions the Windows app paths
  (`%LOCALAPPDATA%\nvim`, `%APPDATA%\alacritty`) to the managed `~/.config` copies.
