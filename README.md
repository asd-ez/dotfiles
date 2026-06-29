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
chezmoi edit ~/.zshrc      # edit a tracked file (opens the source template)
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
| `home/dot_zshrc.tmpl` | `~/.zshrc` | macOS-only libiconv + iTerm2 lines templated |
| `home/dot_profile.tmpl` | `~/.profile` | brew/clipboard/paths templated per OS |
| `home/dot_tmux.conf.tmpl` | `~/.tmux.conf` | fish shell path resolved per OS |
| `home/dot_tool-versions` | `~/.tool-versions` | asdf versions |
| `home/dot_config/nvim/` | `~/.config/nvim/` | LazyVim config |
| `home/dot_config/fish/config.fish.tmpl` | `~/.config/fish/config.fish` | pnpm path templated |
| `home/dot_config/omf/` | `~/.config/omf/` | oh-my-fish |
| `home/dot_config/alacritty/alacritty.toml.tmpl` | `~/.config/alacritty/alacritty.toml` | macOS-only window keys templated |

## OS coverage

- **Linux / WSL2 / macOS**: everything above. WSL2 is treated as Linux.
- **Native Windows**: only **nvim** and **alacritty** (the unix shells, tmux,
  fish and asdf don't apply). Everything else is skipped via `.chezmoiignore`.
  `run_onchange_after_windows-app-links.ps1` junctions the Windows app paths
  (`%LOCALAPPDATA%\nvim`, `%APPDATA%\alacritty`) to the managed `~/.config` copies.
