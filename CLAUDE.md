# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Claude Code plugin providing Rust development support through rust-analyzer LSP integration and 18 automated hooks for code quality, security, and dependency analysis.

## Setup

Run `/setup` to install all required tools, or manually:

```bash
rustup component add rust-analyzer
rustup toolchain install nightly
cargo install cargo-audit cargo-deny cargo-outdated cargo-machete \
              cargo-semver-checks cargo-geiger cargo-expand cargo-bloat \
              cargo-mutants
cargo +nightly install cargo-udeps
```

## Key Files

| File | Purpose |
|------|---------|
| `.lsp.json` | rust-analyzer LSP configuration |
| `hooks/hooks.json` | 18 automated development hooks |
| `commands/setup.md` | `/setup` command definition |
| `.claude-plugin/plugin.json` | Plugin metadata |

## Hook System

All hooks trigger `afterWrite`. Hooks use `command -v` checks to skip gracefully when optional tools aren't installed.

**Hook categories:**
- **Core** (`**/*.rs`): format, check, clippy, test compile
- **Quality** (`**/*.rs`, `**/src/**/*.rs`): doc-check, todo/fixme, unsafe detector
- **Deps** (`**/Cargo.toml`, `**/Cargo.lock`): audit, deny, outdated, machete, udeps
- **Analysis** (`**/src/lib.rs`, `**/Cargo.toml`): semver-checks, geiger
- **Hints** (`**/*.rs`, `**/Cargo.toml`): mutants, bloat, expand, bench suggestions

## When Modifying Hooks

Edit `hooks/hooks.json`. Each hook follows this pattern:

```json
{
    "name": "hook-name",
    "event": "afterWrite",
    "hooks": [{ "type": "command", "command": "..." }],
    "matcher": "**/*.rs"
}
```

- Use `|| true` to prevent hook failures from blocking writes
- Use `head -N` to limit output verbosity
- Use `command -v tool >/dev/null &&` for optional tool dependencies

## When Modifying LSP Config

Edit `.lsp.json`. The `extensionToLanguage` map controls which files use the LSP. Current config maps `.rs` files to the `rust` language server.

## Conventions

- Prefer minimal diffs
- Keep hooks fast (use `--message-format=short`, limit output with `head`)
- Documentation changes: update both README.md and commands/setup.md if relevant
