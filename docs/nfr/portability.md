# NFR: Portability

> Part of [dotfiles documentation](../README.md) · Status: Built · Verified: 2026-08-05

One source tree renders onto four targets: macOS, Linux, WSL2 and native Windows. WSL2 is
treated as Linux. The requirement is not that every target gets everything, it is that every
target gets a coherent subset and that nothing renders into a broken state.

## Requirements

1. **A config never renders a line the platform cannot parse.** Alacritty's `decorations` and
   `option_as_alt` keys are macOS-only and cause a parse failure elsewhere, so they sit behind
   a `darwin` conditional. The general rule: if a setting errors on any target, it is guarded,
   not documented as a caveat.

2. **What a platform cannot use at all is excluded, not degraded.** Native Windows gets no
   `.bashrc`, `.profile` or `.tmux.conf`, via a templated `.chezmoiignore`. A rendered but
   unusable file is worse than an absent one, because it reads as configured.

3. **Capability is detected at runtime where the OS name does not answer the question.** Linux
   may be Wayland, X11 or WSL2, and the clipboard command differs across all three. That probe
   is a runtime conditional in the rendered shell code, not a template conditional. Contrast
   with Homebrew's prefix, which genuinely is a function of the OS and is templated.

4. **A managed config works immediately after apply, with no second install step.** This is why
   no config declares plugins for an external manager
   ([0006](../decisions/0006-no-plugin-managers.md)). A tmux config listing eight uninstalled
   plugins degraded silently for an unknown period.

5. **Nothing assumes a hardcoded user or home path.** All paths derive from `$HOME`. The repo
   previously carried absolute paths from one machine's account.

6. **A guarded block must render to nothing, not to a broken remnant.** The Windows junction
   script renders to zero bytes on Linux, so chezmoi does not execute it. Verified by rendering
   it and measuring the output.

## How to check

```sh
# Render any template for the current platform and read the real output
chezmoi execute-template --init < home/dot_profile.tmpl

# What would this platform actually receive
chezmoi managed

# Preview without writing
chezmoi diff
```

There is no cross-platform rendering check. chezmoi renders for the host it runs on, so
verifying the macOS branches means running on macOS. This is the largest untested surface in
the repo.

## Known gaps

- macOS and Windows branches are written and reviewed but were last exercised on Linux/WSL2
  only. Treat a first apply on either as unproven.
- Requirement 6 is verified for the one script that has a guard. Nothing enforces it for a
  future one.
