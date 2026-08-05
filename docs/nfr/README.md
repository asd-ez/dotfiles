# Non-functional requirements

> Part of [dotfiles documentation](../README.md) · Status: Living · Updated: 2026-08-05

What has to stay true regardless of which config changes. Each file states requirements and,
where one exists, the check that demonstrates it.

These are not aspirational. Every requirement listed has been violated at least once by this
repo, and most were found by looking rather than by failing loudly.

| NFR | Why it matters here |
| --- | --- |
| [portability](portability.md) | One source has to render correctly onto four OS targets. Divergence between machines is the failure this repo exists to prevent. |
| [idempotency](idempotency.md) | Applying twice, and sourcing a shell file twice, must be indistinguishable from doing it once. Nested shells make this a live requirement, not a theoretical one. |
| [startup-latency](startup-latency.md) | Every line in `.profile` and `.bashrc` runs on every shell start. Cost here is paid hundreds of times a day. |
| [recoverability](recoverability.md) | `chezmoi apply` overwrites files in `$HOME`, some of which decide whether a shell starts. There must always be a way back. |
| [secrets](secrets.md) | The repo is public. Anything committed is published permanently, including in history. |
