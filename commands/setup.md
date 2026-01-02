# Rust LSP & Toolchain Setup

Set up rust-analyzer LSP integration and install all cargo tools required by the hooks in this project.

## Instructions

Execute the following setup steps in order:

### 1. Verify Rust Toolchain

Check that rustup and cargo are installed:

```bash
rustup --version && cargo --version
```

If not installed, guide the user to https://rustup.rs/

### 2. Install rust-analyzer

Check if rust-analyzer is available:

```bash
which rust-analyzer || rustup component add rust-analyzer
```

### 3. Install Nightly Toolchain (required for some tools)

```bash
rustup toolchain install nightly
```

### 4. Install Required Cargo Tools

Install all tools used by the hooks in `hooks/hooks.json`:

```bash
# Core tools (required)
cargo install cargo-audit       # Security vulnerability scanning
cargo install cargo-deny        # License and security policy enforcement
cargo install cargo-outdated    # Dependency freshness check

# Enhanced analysis (recommended)
cargo install cargo-machete     # Unused dependency detection (fast)
cargo install cargo-semver-checks  # API compatibility verification
cargo install cargo-geiger      # Unsafe code metrics

# Development aids (optional)
cargo install cargo-expand      # Macro expansion viewer
cargo install cargo-bloat       # Binary size analysis
cargo install cargo-mutants     # Mutation testing

# Nightly-only tools
cargo +nightly install cargo-udeps  # Unused dependencies (comprehensive)
```

### 5. Verify LSP Configuration

Check that `.lsp.json` exists and is properly configured:

```bash
cat .lsp.json
```

Expected configuration:
```json
{
    "rust": {
        "command": "rust-analyzer",
        "args": [],
        "extensionToLanguage": {
            ".rs": "rust"
        },
        "transport": "stdio"
    }
}
```

### 6. Initialize deny.toml (if using cargo-deny)

If this project uses `cargo deny`, ensure `deny.toml` exists:

```bash
[ -f deny.toml ] || cargo deny init
```

### 7. Verify Hooks Configuration

Confirm hooks are loaded:

```bash
cat hooks/hooks.json | head -50
```

## Tool Summary

| Tool | Purpose | Hook |
|------|---------|------|
| `rust-analyzer` | LSP server for IDE features | Core |
| `cargo-audit` | CVE vulnerability scanning | `rust-audit` |
| `cargo-deny` | License/security policy | `rust-deny-check` |
| `cargo-outdated` | Outdated deps | `rust-outdated` |
| `cargo-machete` | Unused deps (fast) | `rust-machete` |
| `cargo-udeps` | Unused deps (thorough) | `rust-unused-deps` |
| `cargo-semver-checks` | API compat | `rust-semver-check` |
| `cargo-geiger` | Unsafe metrics | `rust-geiger` |
| `cargo-expand` | Macro viewer | `rust-expand-hint` |
| `cargo-bloat` | Size analysis | `rust-bloat-hint` |
| `cargo-mutants` | Mutation testing | `rust-mutants-hint` |

## Troubleshooting

### rust-analyzer not starting
- Ensure `Cargo.toml` exists in project root
- Run `cargo check` to generate build artifacts
- Check rust-analyzer logs: `rust-analyzer --version`

### cargo-udeps fails
- Requires nightly: `cargo +nightly udeps`
- May need: `rustup component add rust-src --toolchain nightly`

### cargo-deny errors
- Initialize config: `cargo deny init`
- Update advisories: `cargo deny fetch`

### Hooks not running
- Verify Claude Code hooks are enabled in settings
- Check hook matcher patterns match your file structure

## Quick Install (All Tools)

One-liner to install everything:

```bash
rustup component add rust-analyzer && \
rustup toolchain install nightly && \
cargo install cargo-audit cargo-deny cargo-outdated cargo-machete \
              cargo-semver-checks cargo-geiger cargo-expand cargo-bloat \
              cargo-mutants && \
cargo +nightly install cargo-udeps
```

After running this command, provide a status summary showing which tools were installed successfully and any that failed.
