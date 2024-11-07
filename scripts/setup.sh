#!/bin/sh
# munin-plugin-pack: Helper script to install and configure plugins
# Usage: scripts/setup.sh [install|link|configure|verify]

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_DIR="${MUNIN_PLUGIN_DIR:-/usr/share/munin/plugins}"
CONF_DIR="${MUNIN_CONF_DIR:-/etc/munin/plugin-conf.d}"
EXAMPLE_DIR="${SCRIPT_DIR}/examples"

usage() {
    cat <<EOF
munin-plugin-pack setup helper

Usage: $0 <command> [options]

Commands:
  install   - Copy plugins to Munin plugin directory
  link      - Create symlinks in Munin plugin directory
  configure - Install example configuration
  verify    - Verify plugin setup and dependencies
  list      - List all available plugins
  help      - Show this help message

Environment variables:
  MUNIN_PLUGIN_DIR  Plugin directory (default: /usr/share/munin/plugins)
  MUNIN_CONF_DIR    Config directory (default: /etc/munin/plugin-conf.d)
EOF
}

list_plugins() {
    echo "Available plugins:"
    echo ""
    find "$SCRIPT_DIR/plugins" -type f ! -name '*.bak' ! -name '*.tmp' | sort | while IFS= read -r plugin; do
        category=$(dirname "$plugin" | xargs basename)
        name=$(basename "$plugin")
        desc=$(head -3 "$plugin" | grep -oP '(?<=munin-plugin-pack: ).*' || echo "")
        printf "  %-30s [%-12s] %s\n" "$name" "$category" "$desc"
    done
}

cmd_install() {
    echo "Installing plugins to $PLUGIN_DIR..."
    if [ "$(id -u)" -ne 0 ]; then
        echo "Warning: not running as root. You may need sudo." >&2
    fi

    # Create category subdirectories
    for cat_dir in "$SCRIPT_DIR/plugins"/*/; do
        category=$(basename "$cat_dir")
        mkdir -p "$PLUGIN_DIR/$category"
    done

    # Copy plugins
    cp -v "$SCRIPT_DIR/plugins"/*/* "$PLUGIN_DIR/" 2>/dev/null || \
    find "$SCRIPT_DIR/plugins" -type f -exec cp -v {} "$PLUGIN_DIR/" \;

    # Set permissions
    find "$PLUGIN_DIR" -name 'docker_*' -o -name 'smart_*' -o -name 'ssh_*' \
        -o -name 'firewall_*' -o -name 'backup_*' -o -name 'log_monitor' \
        -o -name 'cpu_*' -o -name 'k8s_*' -o -name 'latency' \
        -o -name 'ssl_*' -o -name 'nginx_*' -o -name 'api_*' \
        -o -name 'qdrant_*' 2>/dev/null | while IFS= read -r f; do
        chmod 755 "$f"
    done

    echo ""
    echo "Plugins installed. Restart munin-node:"
    echo "  systemctl restart munin-node"
}

cmd_link() {
    echo "Creating symlinks in $PLUGIN_DIR..."
    mkdir -p "$PLUGIN_DIR"

    find "$SCRIPT_DIR/plugins" -type f ! -name '*.bak' ! -name '*.tmp' | while IFS= read -r plugin; do
        name=$(basename "$plugin")
        ln -sfv "$plugin" "$PLUGIN_DIR/$name"
    done

    echo ""
    echo "Symlinks created. Restart munin-node:"
    echo "  systemctl restart munin-node"
}

cmd_configure() {
    echo "Installing example configuration..."
    if [ "$(id -u)" -ne 0 ]; then
        echo "Warning: not running as root." >&2
    fi

    if [ -d "$CONF_DIR" ]; then
        if [ -f "$EXAMPLE_DIR/munin-plugin-conf.d" ]; then
            cp -v "$EXAMPLE_DIR/munin-plugin-conf.d" "$CONF_DIR/munin-plugin-pack"
        fi
        if [ -f "$EXAMPLE_DIR/log-monitor.conf" ]; then
            cp -v "$EXAMPLE_DIR/log-monitor.conf" /etc/munin/log-monitor.conf
        fi
        echo "Configuration installed to $CONF_DIR"
    else
        echo "Warning: $CONF_DIR does not exist. Copy files manually."
    fi
}

cmd_verify() {
    echo "Verifying plugin installation..."
    echo ""

    errors=0

    # Check plugin directory exists
    if [ -d "$PLUGIN_DIR" ]; then
        echo "Plugin directory: $PLUGIN_DIR (OK)"
    else
        echo "Plugin directory: $PLUGIN_DIR (MISSING)"
        errors=$((errors + 1))
    fi

    # Check each plugin
    find "$SCRIPT_DIR/plugins" -type f ! -name '*.bak' ! -name '*.tmp' | while IFS= read -r plugin; do
        name=$(basename "$plugin")
        if [ -x "$PLUGIN_DIR/$name" ]; then
            printf "  %-30s OK\n" "$name"
        elif [ -L "$PLUGIN_DIR/$name" ]; then
            printf "  %-30s LINKED\n" "$name"
        else
            printf "  %-30s NOT INSTALLED\n" "$name"
        fi
    done

    echo ""

    # Check dependencies
    echo "Checking dependencies..."
    for cmd in docker curl openssl ping; do
        if command -v "$cmd" >/dev/null 2>&1; then
            printf "  %-20s OK\n" "$cmd"
        else
            printf "  %-20s NOT FOUND\n" "$cmd"
        fi
    done

    if [ "$errors" -gt 0 ]; then
        echo ""
        echo "Found $errors error(s)."
        return 1
    fi
}

# --- Main ---
case "${1:-help}" in
    install)   cmd_install ;;
    link)      cmd_link ;;
    configure) cmd_configure ;;
    verify)    cmd_verify ;;
    list)      list_plugins ;;
    help|*)    usage ;;
esac
