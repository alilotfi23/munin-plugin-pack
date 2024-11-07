#!/bin/sh
# test-plugins.sh - Validate all Munin plugins
# Tests: shebang, config output, metric format, error handling
#
# SPDX-License-Identifier: MIT

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGINS_DIR="$SCRIPT_DIR/plugins"

# Accumulator files (portable way to count across subshells)
TMPDIR_USE="${TMPDIR:-/tmp}"
PASS_FILE="$TMPDIR_USE/mpp_pass.$$"
FAIL_FILE="$TMPDIR_USE/mpp_fail.$$"
WARN_FILE="$TMPDIR_USE/mpp_warn.$$"
: > "$PASS_FILE"
: > "$FAIL_FILE"
: > "$WARN_FILE"

cleanup() {
    rm -f "$PASS_FILE" "$FAIL_FILE" "$WARN_FILE"
}
trap cleanup EXIT INT TERM

# Colors (if terminal supports them)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    GREEN=''
    RED=''
    YELLOW=''
    NC=''
fi

# Build the list of plugins once (avoids re-running find in subshells)
PLUGINS=$(find "$PLUGINS_DIR" -type f ! -name '*.bak' ! -name '*.tmp' | sort)

pass() {
    printf '.' >> "$PASS_FILE"
    printf "${GREEN}  PASS${NC} %s\n" "$1"
}

fail() {
    printf 'x: %s\n' "$1" >> "$FAIL_FILE"
    printf "${RED}  FAIL${NC} %s\n" "$1"
}

warn() {
    printf '.' >> "$WARN_FILE"
    printf "${YELLOW}  WARN${NC} %s\n" "$1"
}

echo "======================================="
echo " munin-plugin-pack Plugin Test Suite"
echo "======================================="
echo ""

# ── Test 1: Executable permissions ──────────────────────────────────
echo "--- Test: Executable permissions ---"
echo "$PLUGINS" | while IFS= read -r plugin; do
    if [ -x "$plugin" ]; then
        pass "$(basename "$plugin") is executable"
    else
        fail "$(basename "$plugin") is NOT executable"
    fi
done
echo ""

# ── Test 2: Shebang line ───────────────────────────────────────────
echo "--- Test: Shebang lines ---"
echo "$PLUGINS" | while IFS= read -r plugin; do
    first_line=$(head -1 "$plugin")
    if echo "$first_line" | grep -qE '^#!/bin/(sh|bash)'; then
        pass "$(basename "$plugin"): valid shebang ($first_line)"
    else
        fail "$(basename "$plugin"): invalid shebang ($first_line)"
    fi
done
echo ""

# ── Test 3: Config output ──────────────────────────────────────────
echo "--- Test: Config output ---"
echo "$PLUGINS" | while IFS= read -r plugin; do
    name=$(basename "$plugin")
    output=$("$plugin" config 2>&1) || true

    if echo "$output" | grep -q "graph_title"; then
        pass "$name config: graph_title present"
    else
        fail "$name config: graph_title MISSING"
    fi

    if echo "$output" | grep -q "graph_category"; then
        pass "$name config: graph_category present"
    else
        fail "$name config: graph_category MISSING"
    fi

    if echo "$output" | grep -q "graph_vlabel"; then
        pass "$name config: graph_vlabel present"
    else
        warn "$name config: graph_vlabel missing"
    fi

    if echo "$output" | grep -q "graph_info"; then
        pass "$name config: graph_info present"
    else
        warn "$name config: graph_info missing"
    fi

    # Check for at least one .label definition
    if echo "$output" | grep -qE '\.label '; then
        pass "$name config: metric labels present"
    else
        fail "$name config: no .label definitions found"
    fi
done
echo ""

# ── Test 4: Metric output format ──────────────────────────────────
echo "--- Test: Metric output format ---"
echo "$PLUGINS" | while IFS= read -r plugin; do
    name=$(basename "$plugin")
    output=$("$plugin" 2>&1) || true

    # Valid metric lines end with .value followed by a number or U
    valid_count=$(echo "$output" | grep -cE '\.value (U|[0-9])' 2>/dev/null || true)

    if [ "${valid_count:-0}" -gt 0 ]; then
        pass "$name metrics: $valid_count valid metric(s)"
    elif [ -z "$output" ]; then
        warn "$name metrics: no output (dependency missing?)"
    else
        fail "$name metrics: no valid .value lines found"
    fi
done
echo ""

# ── Test 5: Autoconf support ──────────────────────────────────────
echo "--- Test: Autoconf support ---"
echo "$PLUGINS" | while IFS= read -r plugin; do
    name=$(basename "$plugin")
    output=$("$plugin" autoconf 2>&1) || true

    if echo "$output" | grep -qiE '^(yes|no)'; then
        pass "$name autoconf: responds with yes/no"
    else
        warn "$name autoconf: does not respond with yes/no"
    fi
done
echo ""

# ── Test 6: No hardcoded dangerous paths ──────────────────────────
echo "--- Test: Security - no temp files in /tmp ---"
echo "$PLUGINS" | while IFS= read -r plugin; do
    name=$(basename "$plugin")
    if grep -q '/tmp/' "$plugin" 2>/dev/null; then
        warn "$name: references /tmp (ensure safe tempfile handling)"
    else
        pass "$name: no /tmp references"
    fi
done
echo ""

# ── Test 7: License headers ────────────────────────────────────────
echo "--- Test: License headers ---"
echo "$PLUGINS" | while IFS= read -r plugin; do
    name=$(basename "$plugin")
    if grep -q 'SPDX-License-Identifier' "$plugin"; then
        pass "$name: SPDX license identifier present"
    else
        warn "$name: missing SPDX license identifier"
    fi
done
echo ""

# ── Summary ────────────────────────────────────────────────────────
PASS_COUNT=$(wc -c < "$PASS_FILE" | tr -d '[:space:]')
FAIL_COUNT=$(wc -l < "$FAIL_FILE" | tr -d '[:space:]')
WARN_COUNT=$(wc -c < "$WARN_FILE" | tr -d '[:space:]')

echo "======================================="
echo " Test Results"
echo "======================================="
printf "  Passed:   %s\n" "$PASS_COUNT"
printf "  Failed:   %s\n" "$FAIL_COUNT"
printf "  Warnings: %s\n" "$WARN_COUNT"
echo "======================================="

if [ "${FAIL_COUNT:-0}" -gt 0 ]; then
    echo ""
    echo "Failures:"
    cat "$FAIL_FILE"
    exit 1
else
    exit 0
fi
