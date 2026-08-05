# NFR: Shell startup latency

> Part of [dotfiles documentation](../README.md) · Status: Built · Verified: 2026-08-05

Every line in `.profile` and `.bashrc` runs on every shell start. A new shell opens dozens of
times a day, plus once per tmux pane and once per subshell, so cost here is paid at a rate
nothing else in the repo comes close to.

This is the requirement most in tension with [portability](portability.md), which wants
runtime capability probes, and each probe is a subprocess.

## Requirements

1. **No unconditional network access.** Nothing in a startup path may contact the network. A
   slow or captive network would hang every new shell.

2. **Subprocesses at startup are justified individually.** Current cost, all in `.profile`:
   - `locale -a` once, to decide whether the locale is safe to export
   - `command -v pyenv` twice, and `pyenv init -` when present
   - up to three `command -v` probes for the clipboard tool
   - `brew shellenv` on macOS only

   Each exists because a template conditional cannot answer the question. Anything that a
   template can answer belongs in the template, where it costs nothing at runtime.

3. **Guards are cheap where they can be.** `__path_prepend` uses a `case` statement on a
   string, which is a shell builtin, not `grep` or `tr` in a subshell. It runs six times per
   startup, so the difference between a builtin and a subprocess is the whole cost.

4. **Interactive-only work stays in `.bashrc`, behind its non-interactive early return.**
   Prompt, history and completion setup must not run in a non-interactive `sh`. `.bashrc`
   returns immediately when not interactive.

5. **Completion is loaded from the first path that exists, not all of them.** The chain in
   `.bashrc` stops at the first match.

## How to check

```sh
# Wall time for a full login shell start
time bash -lic true

# Trace what actually runs, to find an unexpected subprocess
PS4='+ $EPOCHREALTIME $BASH_SOURCE:$LINENO: ' bash -lixc true 2>&1 | tail -40
```

There is no budget number, deliberately. The requirement is that every subprocess is
attributable to a line someone chose, which the trace above shows directly.

## Known gaps

- No measurement is recorded here, so there is no regression baseline. Capture one before and
  after any change that adds a startup subprocess.
- `pyenv init -` is the most expensive single line when pyenv is installed. It is currently
  installed on no machine in use, so its cost has not been measured.
