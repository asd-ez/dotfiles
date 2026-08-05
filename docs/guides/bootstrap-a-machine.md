# Bootstrap a machine

> Part of [guides](README.md) · Status: Living · Updated: 2026-08-05

Two situations, and they differ in one important way: whether `$HOME` already has files that
apply would overwrite.

## Fresh machine, nothing to lose

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply asd-ez/dotfiles
```

This installs chezmoi, clones the repo into chezmoi's own source directory, and applies it.

On Windows (PowerShell):

```powershell
(irm -useb get.chezmoi.io/ps1) | powershell -c -
chezmoi init --apply asd-ez/dotfiles
```

Windows receives nvim and alacritty only, junctioned into the locations those applications
read. See [0008](../decisions/0008-windows-junctions-not-symlinks.md).

## Existing machine with real config

Do not run the one-liner. It applies immediately, and the first thing it overwrites is the
shell config you are currently sitting in.

**1. See what would change.** Point chezmoi at an existing clone by creating
`~/.config/chezmoi/chezmoi.toml`:

```toml
sourceDir = "/absolute/path/to/dotfiles"
```

Then confirm it resolved, and read the plan:

```sh
chezmoi source-path        # should print <repo>/home, not chezmoi's default
chezmoi managed            # every file apply would write
chezmoi diff               # every change it would make
```

`chezmoi source-path` printing something else means the config was not picked up, and an
apply would do nothing useful.

**2. Back up what exists.** Only the files that already exist matter; the rest are new.

```sh
mkdir -p ~/dotfiles-backup-pre-chezmoi
for f in .profile .bashrc .bash_aliases .tmux.conf; do
  [ -e "$HOME/$f" ] && cp -a "$HOME/$f" ~/dotfiles-backup-pre-chezmoi/
done
ls -la ~/dotfiles-backup-pre-chezmoi/   # -a, or you will see an empty directory
```

**3. Check what only the local files provide.** This is the step that is easy to skip and
expensive to skip. A live `~/.bashrc` commonly holds environment that exists in no repo:
language toolchains, private module settings, PATH entries added by an installer.

```sh
diff <(chezmoi cat ~/.bashrc) ~/.bashrc | grep '^>'
```

Anything in that output disappears on apply. Move what matters into the repo, or into
`~/.bash_aliases` if it is machine-specific
([0009](../decisions/0009-machine-local-escape-hatch.md)).

**4. Apply, then verify both shell entry paths.**

```sh
chezmoi apply
chezmoi status              # empty means fully applied

bash -lic 'alias; echo "$PATH"'   # login
bash -ic  'alias; echo "$PATH"'   # non-login
```

Both must agree. If they do not, see [troubleshooting](troubleshooting.md).

## Afterwards

Neither path installs the optional tooling, by design
([0006](../decisions/0006-no-plugin-managers.md)). If you want it:

```sh
sudo locale-gen en_US.UTF-8 && sudo update-locale   # otherwise LANG stays at the system default
```

Nothing else is required. The managed configs work as applied.
