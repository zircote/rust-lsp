# rust-lsp

A Claude Code plugin providing comprehensive Rust development support through:

- **rust-analyzer LSP** integration for IDE-like features
- **16 automated hooks** for code quality, security, and analysis
- **Cargo tool ecosystem** integration

## Quick Setup

```bash
# Run the setup command (after installing the plugin)
/setup
```

Or manually:

```bash
# Install rust-analyzer
rustup component add rust-analyzer

# Install nightly toolchain (required for some tools)
rustup toolchain install nightly

# Install all cargo tools
cargo install cargo-audit cargo-deny cargo-outdated cargo-machete \
              cargo-semver-checks cargo-geiger cargo-expand cargo-bloat \
              cargo-mutants && \
cargo +nightly install cargo-udeps
```

## Features

### LSP Integration

The plugin configures rust-analyzer for Claude Code via `.lsp.json`:

```json
{
    "rust": {
        "command": "rust-analyzer",
        "args": [],
        "extensionToLanguage": { ".rs": "rust" },
        "transport": "stdio"
    }
}
```

**Capabilities:**
- Go to definition / references
- Hover documentation
- Code actions and quick fixes
- Workspace symbol search
- Real-time diagnostics

### Automated Hooks

All hooks run `afterWrite` and are configured in `hooks/hooks.json`.

#### Core Rust Hooks

| Hook | Trigger | Description |
|------|---------|-------------|
| `rust-format-on-edit` | `**/*.rs` | Auto-format with `rustfmt` |
| `rust-check-on-edit` | `**/*.rs` | Compile check with `cargo check` |
| `rust-clippy-on-edit` | `**/*.rs` | Lint with `cargo clippy` |
| `rust-test-compile-on-edit` | `**/*.rs` | Verify tests compile (`cargo test --no-run`) |

#### Documentation & Quality

| Hook | Trigger | Description |
|------|---------|-------------|
| `rust-doc-check` | `**/src/**/*.rs` | Check rustdoc for warnings/errors |
| `rust-todo-fixme` | `**/*.rs` | Surface TODO/FIXME/XXX/HACK comments |
| `rust-unsafe-detector` | `**/*.rs` | Flag `unsafe` blocks for review |

#### Dependency Management

| Hook | Trigger | Tool Required | Description |
|------|---------|---------------|-------------|
| `rust-audit` | `**/Cargo.lock` | `cargo-audit` | CVE vulnerability scanning |
| `rust-deny-check` | `**/Cargo.toml` | `cargo-deny` | License/security policy enforcement |
| `rust-outdated` | `**/Cargo.toml` | `cargo-outdated` | Check for outdated dependencies |
| `rust-machete` | `**/Cargo.toml` | `cargo-machete` | Fast unused dependency detection |
| `rust-unused-deps` | `**/Cargo.toml` | `cargo-udeps` | Thorough unused dependency check (nightly) |

#### Advanced Analysis

| Hook | Trigger | Tool Required | Description |
|------|---------|---------------|-------------|
| `rust-semver-check` | `**/src/lib.rs` | `cargo-semver-checks` | API compatibility verification |
| `rust-geiger` | `**/Cargo.toml` | `cargo-geiger` | Unsafe code ratio in dependencies |

#### Contextual Hints

| Hook | Trigger | Description |
|------|---------|-------------|
| `rust-mutants-hint` | `**/src/**/*.rs` | Suggests mutation testing when available |
| `rust-bloat-hint` | `**/Cargo.toml` | Suggests binary size analysis |
| `rust-expand-hint` | `**/*.rs` | Suggests macro expansion when macros detected |
| `rust-bench-hint` | `**/*.rs` | Suggests benchmark run when benchmarks detected |

#### Other

| Hook | Trigger | Description |
|------|---------|-------------|
| `markdown-lint-on-edit` | `**/*.md` | Lint markdown files |

## Required Tools

### Core (Included with Rust)

| Tool | Installation | Purpose |
|------|--------------|---------|
| `rustfmt` | `rustup component add rustfmt` | Code formatting |
| `clippy` | `rustup component add clippy` | Linting |
| `rust-analyzer` | `rustup component add rust-analyzer` | LSP server |

### Recommended Cargo Extensions

| Tool | Installation | Purpose |
|------|--------------|---------|
| `cargo-audit` | `cargo install cargo-audit` | Security vulnerability database |
| `cargo-deny` | `cargo install cargo-deny` | License and security policy |
| `cargo-outdated` | `cargo install cargo-outdated` | Dependency freshness |
| `cargo-machete` | `cargo install cargo-machete` | Unused dependencies (fast) |

### Optional Cargo Extensions

| Tool | Installation | Purpose |
|------|--------------|---------|
| `cargo-udeps` | `cargo +nightly install cargo-udeps` | Unused dependencies (thorough) |
| `cargo-semver-checks` | `cargo install cargo-semver-checks` | Semver compatibility |
| `cargo-geiger` | `cargo install cargo-geiger` | Unsafe code metrics |
| `cargo-expand` | `cargo install cargo-expand` | Macro expansion |
| `cargo-bloat` | `cargo install cargo-bloat` | Binary size analysis |
| `cargo-mutants` | `cargo install cargo-mutants` | Mutation testing |

## Commands

### `/setup`

Interactive setup wizard for configuring the complete Rust development environment.

**What it does:**

1. **Verifies Rust toolchain** - Checks `rustup` and `cargo` installation
2. **Installs rust-analyzer** - LSP server for IDE features
3. **Installs nightly toolchain** - Required for `cargo-udeps`
4. **Installs cargo tools** - All 10 recommended extensions
5. **Validates LSP config** - Confirms `.lsp.json` is correct
6. **Initializes deny.toml** - Sets up security/license policy (if needed)
7. **Verifies hooks** - Confirms hooks are properly loaded

**Usage:**

```bash
/setup
```

**Quick install command** (from the wizard):

```bash
rustup component add rust-analyzer && \
rustup toolchain install nightly && \
cargo install cargo-audit cargo-deny cargo-outdated cargo-machete \
              cargo-semver-checks cargo-geiger cargo-expand cargo-bloat \
              cargo-mutants && \
cargo +nightly install cargo-udeps
```

| Command | Description |
|---------|-------------|
| `/setup` | Full interactive setup for LSP and all cargo tools |

## Configuration

### deny.toml

If using `cargo-deny`, initialize configuration:

```bash
cargo deny init
```

This creates `deny.toml` for configuring:
- Allowed/denied licenses
- Security advisory settings
- Duplicate dependency rules

### Customizing Hooks

Edit `hooks/hooks.json` to:
- Disable hooks by removing entries
- Adjust output limits (`head -N`)
- Modify matchers for different file patterns
- Add project-specific hooks

Example - disable a hook:
```json
{
    "name": "rust-geiger",
    "enabled": false,
    ...
}
```

## Project Structure

```
rust-lsp/
├── .claude/
│   └── commands/
│       └── setup.md          # /setup command
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata
├── .lsp.json                  # rust-analyzer configuration
├── hooks/
│   └── hooks.json            # 16 automated hooks
├── CLAUDE.md                  # Project instructions
└── README.md                  # This file
```

## Troubleshooting

### rust-analyzer not starting

1. Ensure `Cargo.toml` exists in project root
2. Run `cargo check` to generate initial build artifacts
3. Verify installation: `rust-analyzer --version`
4. Check LSP config: `cat .lsp.json`

### cargo-udeps fails

Requires nightly toolchain:
```bash
rustup toolchain install nightly
rustup component add rust-src --toolchain nightly
cargo +nightly udeps
```

### cargo-deny errors

Initialize and update:
```bash
cargo deny init
cargo deny fetch
```

### Hooks not triggering

1. Verify hooks are loaded: `cat hooks/hooks.json`
2. Check file patterns match your structure
3. Ensure required tools are installed (`command -v cargo-audit`)

### Too much output

Reduce `head -N` values in hooks.json for less verbose output.

## License

MIT
