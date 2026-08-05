# NFR: Recoverability

> Part of [dotfiles documentation](../README.md) · Status: Built · Verified: 2026-08-05

`chezmoi apply` overwrites files in `$HOME`. Some of them decide whether a login shell starts
at all. A mistake in `.profile` or `.bashrc` is not a cosmetic bug; it can be the difference
between a working terminal and one that errors on every prompt.

There must always be a way back, and it must not depend on having a working shell.

## Requirements

1. **A first apply on a machine backs up what it replaces.** The files that already exist and
   are about to be overwritten get copied somewhere outside `$HOME`'s managed set before the
   apply. This is currently a manual step, documented in
   [bootstrap a machine](../guides/bootstrap-a-machine.md).

2. **Preview precedes apply.** `chezmoi diff` shows exactly what changes. For the shell files
   this is not optional, and the habit matters more than any single check.

3. **A change to a shell file is tested in an isolated home before it reaches the real one.**
   Rendering into a scratch directory and starting a shell against it catches syntax errors and
   infinite loops without risking the live account:

   ```sh
   SB=$(mktemp -d)
   chezmoi execute-template --init < home/dot_profile.tmpl > "$SB/.profile"
   cp home/dot_bashrc "$SB/.bashrc"
   timeout 15 env -i HOME="$SB" TERM=xterm PATH=/usr/bin:/bin bash -lic 'echo ok'
   ```

   The `timeout` is the point. A recursion bug between `.profile` and `.bashrc` hangs, and a
   hang without a timeout in your real home directory is how a terminal stops opening.

4. **Deleting a source file is a two-step operation, and the second step is manual.** chezmoi
   does not remove a target when its source disappears; the file is simply unmanaged from then
   on. The orphan has to be removed by hand. This is a safety property, not a defect, but it
   is easy to leave a stale file behind believing it is gone.

5. **The repo is the source of truth, and it is remote.** Everything managed can be restored
   from a clone. What cannot is the machine-local file
   ([0009](../decisions/0009-machine-local-escape-hatch.md)), which is unmanaged by design and
   therefore unreplicated.

6. **A broken shell is recoverable without that shell.** `bash --norc --noprofile` starts a
   shell that reads neither file, which is the escape hatch when a managed file is the problem.

## How to check

```sh
chezmoi diff                    # what apply would change
chezmoi status                  # empty means fully applied
bash --norc --noprofile         # a shell that ignores both managed files
```

## Known gaps

- Backups are manual and ad hoc. There is no convention for where they live or when they are
  pruned, so a second apply on the same machine may overwrite the backup from the first.
- No rollback command. Recovery means restoring from the backup directory or from git, by hand.
- Point 3 is a documented practice, not an enforced one. Nothing prevents applying an untested
  shell file directly.
