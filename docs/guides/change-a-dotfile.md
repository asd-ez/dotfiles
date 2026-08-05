# Change a dotfile

> Part of [guides](README.md) · Status: Living · Updated: 2026-08-05

The rule that catches everyone: **edit the source, never the target.** Editing `~/.bashrc`
directly works until the next `chezmoi apply` silently discards it.

## Edit a managed file

```sh
chezmoi edit ~/.bashrc     # opens the source file, not the target
chezmoi diff               # what this would change
chezmoi apply
```

Or edit `home/dot_bashrc` in the repo directly, which is the same thing.

For any change to `home/dot_profile.tmpl` or `home/dot_bashrc`, test in an isolated home
first. These two files decide whether a shell starts:

```sh
SB=$(mktemp -d)
chezmoi execute-template --init < home/dot_profile.tmpl > "$SB/.profile"
cp home/dot_bashrc "$SB/.bashrc"
timeout 15 env -i HOME="$SB" TERM=xterm PATH=/usr/bin:/bin bash -lic 'echo ok; alias'
timeout 15 env -i HOME="$SB" TERM=xterm PATH=/usr/bin:/bin bash -ic  'echo ok; alias'
```

Keep the `timeout`. A recursion bug between the two files hangs rather than erroring, and a
hang in your real home directory means terminals stop opening.

## Add a new file

```sh
chezmoi add ~/.newrc               # plain file
chezmoi add --template ~/.newrc    # if it needs per-OS branches
```

`chezmoi add` copies the current contents into the repo with the right source name. Then
commit it.

## Add something to PATH

Use the helper. Do not write `export PATH="...:$PATH"`, which duplicates on every nested shell
([0007](../decisions/0007-idempotent-path-construction.md)):

```sh
__path_prepend "$HOME/some/bin"
```

## Remove a file

Two steps, and chezmoi only does the first:

```sh
git rm home/dot_something          # stop managing it
chezmoi apply                      # note: does NOT delete ~/.something
rm ~/.something                    # the orphan, by hand
```

Removing the source leaves the target in place, unmanaged. Confirm nothing is left behind:

```sh
chezmoi managed | grep something   # should print nothing
ls -la ~/.something                # should not exist
```

On other machines the orphan also has to be removed by hand. chezmoi's `.chezmoiremove` can
propagate deletions automatically, but it keeps deleting forever, so it is not used here.

## Before committing

```sh
chezmoi execute-template --init < home/dot_something.tmpl   # templates still render
chezmoi status                                              # empty
```

If the change alters a decision recorded in [decisions](../decisions/README.md), add a new
record superseding the old one. Do not edit a decision in place: the rejected alternatives are
the most valuable part, and rewriting deletes them.
