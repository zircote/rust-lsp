#!/bin/bash
# Rust development hooks dispatcher
# Reads tool input from stdin and runs appropriate checks based on file type

set -o pipefail

# Read JSON input from stdin
input=$(cat)

# Extract file path from tool_input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Exit if no file path
[ -z "$file_path" ] && exit 0

# Get file extension and name
ext="${file_path##*.}"
filename=$(basename "$file_path")

case "$ext" in
    rs)
        # Format
        rustfmt "$file_path" 2>/dev/null || true

        # Check
        cargo check --message-format=short 2>&1 | head -20 || true

        # Clippy
        cargo clippy --message-format=short -- -W clippy::all 2>&1 | head -30 || true

        # Test compile
        cargo test --no-run --message-format=short 2>&1 | head -20 || true

        # Unsafe detector
        if grep -qn 'unsafe' "$file_path" 2>/dev/null; then
            grep -n 'unsafe' "$file_path" | head -5
            echo '⚠️  Unsafe code detected'
        fi

        # TODO/FIXME check
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Doc check for src files
        if [[ "$file_path" == */src/*.rs ]]; then
            cargo doc --no-deps --document-private-items 2>&1 | grep -E '(warning|error)' | head -15 || true
        fi

        # Macro expand hint
        if grep -qE '#\[derive|macro_rules!' "$file_path" 2>/dev/null; then
            echo "💡 Expand macros: cargo expand"
        fi

        # Bench hint
        if grep -qE '#\[bench\]|criterion' "$file_path" 2>/dev/null; then
            echo "💡 Run benchmarks: cargo bench"
        fi

        # Mutants hint for src files
        if [[ "$file_path" == */src/*.rs ]] && command -v cargo-mutants >/dev/null 2>&1; then
            echo "💡 Mutation test: cargo mutants --file \"$file_path\""
        fi

        # Semver check for lib.rs
        if [[ "$filename" == "lib.rs" ]] && command -v cargo-semver-checks >/dev/null 2>&1; then
            cargo semver-checks check-release 2>&1 | head -20 || true
        fi
        ;;

    md)
        # Markdown lint
        if command -v npx >/dev/null 2>&1; then
            npx markdownlint-cli "$file_path" 2>&1 | head -20 || true
        fi
        ;;

    toml)
        if [[ "$filename" == "Cargo.toml" ]]; then
            # Audit
            command -v cargo-audit >/dev/null 2>&1 && cargo audit 2>&1 | head -20 || true

            # Outdated
            command -v cargo-outdated >/dev/null 2>&1 && cargo outdated --depth 1 2>&1 | head -15 || true

            # Machete (unused deps)
            command -v cargo-machete >/dev/null 2>&1 && cargo machete --skip-target-dir 2>&1 | head -10 || true

            # Udeps (nightly)
            command -v cargo-udeps >/dev/null 2>&1 && cargo +nightly udeps --quiet 2>&1 | head -10 || true

            # Deny check
            [ -f deny.toml ] && cargo deny check 2>&1 | grep -E '(error|warning|WARN)' | head -15 || true

            # Geiger
            command -v cargo-geiger >/dev/null 2>&1 && cargo geiger --update-readme --output-format ratio 2>&1 | tail -5 || true

            # Bloat hint
            command -v cargo-bloat >/dev/null 2>&1 && echo "💡 Size analysis: cargo bloat --release --crates"
        fi
        ;;

    lock)
        if [[ "$filename" == "Cargo.lock" ]]; then
            # Audit on lock file changes
            command -v cargo-audit >/dev/null 2>&1 && cargo audit 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
