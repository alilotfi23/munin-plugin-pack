#!/bin/sh
# test-lint.sh - ShellCheck linter wrapper
# Runs ShellCheck on all shell scripts in the project.
#
# SPDX-License-Identifier: MIT

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Running ShellCheck ==="

if ! command -v shellcheck >/dev/null 2>&1; then
    echo "ShellCheck is not installed."
    echo "Install with: apt-get install shellcheck (Debian/Ubuntu)"
    echo "           or: dnf install shellcheck (Fedora/RHEL)"
    echo "           or: brew install shellcheck (macOS)"
    exit 1
fi

errors=0

# Lint all plugins
for plugin in "$SCRIPT_DIR/plugins"/*/*; do
    [ -f "$plugin" ] || continue
    echo "Checking: $(basename "$plugin")"
    shellcheck --severity=warning --shell=sh "$plugin" || errors=$((errors + 1))
done

# Lint test scripts
for test in "$SCRIPT_DIR/tests"/*.sh; do
    [ -f "$test" ] || continue
    echo "Checking: $(basename "$test")"
    shellcheck --severity=warning --shell=sh "$test" || errors=$((errors + 1))
done

# Lint helper scripts
for script in "$SCRIPT_DIR/scripts"/*.sh; do
    [ -f "$script" ] || continue
    echo "Checking: $(basename "$script")"
    shellcheck --severity=warning --shell=sh "$script" || errors=$((errors + 1))
done

echo ""
if [ "$errors" -gt 0 ]; then
    echo "ShellCheck found $errors file(s) with warnings/errors."
    exit 1
else
    echo "ShellCheck passed: no issues found."
    exit 0
fi
