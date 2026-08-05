# NFR: Secrets

> Part of [dotfiles documentation](../README.md) · Status: Built · Verified: 2026-08-05

This repository is **public**. Anything committed is published permanently and remains in git
history after deletion. Dotfiles are an unusually easy place to leak a credential, because
shell config is exactly where people put API tokens.

## Requirements

1. **No credentials, tokens or keys in any managed file.** Not in a template, not in a
   comment, not in git history. The current tree contains none; the only environment variable
   resembling a credential setting is `GOPRIVATE`, which is a module path pattern, not a secret.

2. **Machine-specific or private values go in the unmanaged local file.**
   `~/.bash_aliases` is never committed and is the sanctioned home for anything that should
   not be shared ([0009](../decisions/0009-machine-local-escape-hatch.md)).

3. **A leaked secret is rotated, not just deleted.** Removing it from the working tree does not
   remove it from history, from clones, or from GitHub's cached views. Treat any commit as
   published the moment it is pushed.

4. **Rewriting history to remove a secret is not sufficient on its own.** It is worth doing, but
   rotation is what actually closes the exposure. History rewriting on `master` also requires
   temporarily relaxing branch protection, which is its own risk.

5. **Nothing in a startup path prints a secret.** No `echo` of an environment variable in
   `.profile` or `.bashrc`, since shell startup output ends up in logs, screen shares and
   recordings.

## How to check

```sh
# Scan the working tree
grep -rIn -iE '(api[_-]?key|secret|token|password|BEGIN [A-Z ]*PRIVATE KEY)' home/

# Scan all of history, which is what actually matters
git log -p --all | grep -inE '(api[_-]?key|secret|token|password|BEGIN [A-Z ]*PRIVATE KEY)'
```

Both are pattern matches and will miss anything not shaped like the patterns. They are a
backstop, not a guarantee.

## Known gaps

- No automated scanning. No pre-commit hook, no CI secret scan. GitHub's push protection may
  catch well-known token formats, but nothing in this repo enforces anything.
- Requirement 2 depends entirely on discipline. Nothing prevents a secret being typed into a
  managed file, and the tooling makes it convenient to do so.
- The chezmoi-supported alternative, an external secret manager or age encryption, is not set
  up. That is the right answer if a genuine secret ever needs to be shared across machines.
