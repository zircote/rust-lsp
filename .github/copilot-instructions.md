# Copilot instructions

You are working in a Claude Code plugin for Rust development with LSP and automated hooks.

## Priorities

1. Keep changes small and reviewable.
2. Hooks must be fast and fail-open (use `|| true`).
3. Update README.md and commands/setup.md when changing user-facing behavior.

## Key Files

- `.lsp.json` - rust-analyzer LSP configuration
- `hooks/hooks.json` - 18 automated development hooks
- `commands/setup.md` - `/setup` command for toolchain installation

## Commands

- Setup: `/setup` (installs rust-analyzer and all cargo tools)
- Manual install: See `commands/setup.md` for the full toolchain

## When Adding Hooks

Use this pattern in `hooks/hooks.json`:

```json
{
    "name": "hook-name",
    "event": "afterWrite",
    "hooks": [{ "type": "command", "command": "command -v tool && tool args | head -N || true" }],
    "matcher": "**/*.rs"
}
```
