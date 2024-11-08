# Contributing to munin-plugin-pack

Thank you for your interest in contributing to munin-plugin-pack!
This guide covers everything you need to create, test, and submit plugins.

## Getting Started

### Prerequisites

- A Linux system (Debian/Ubuntu, RHEL/CentOS, or Arch Linux)
- Munin-node installed (`apt install munin-node` or equivalent)
- ShellCheck (`apt install shellcheck`)
- Git
- Basic shell scripting knowledge

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/munin-plugin-pack.git
   cd munin-plugin-pack
   ```
3. Run tests to verify everything works:
   ```bash
   make test
   make lint
   ```

## Adding a New Plugin

### File Location

Place your plugin in the appropriate category directory under `plugins/`:

```
plugins/
├── docker/       # Docker-related monitoring
├── security/     # Security monitoring
├── disk/         # Storage monitoring
├── network/      # Network monitoring
├── system/       # System metrics
├── backup/       # Backup monitoring
├── kubernetes/   # Kubernetes monitoring
├── web/          # Web server / API monitoring
├── qdrant/       # Database monitoring
└── api/          # Generic API / log monitoring
```

### Plugin Template

Every plugin MUST follow this structure:

```sh
#!/bin/sh
# munin-plugin-pack: Plugin Name
# Brief description of what this plugin monitors.
#
# Requirements: list of external commands needed
# Config variables:
#   variable_name - Description (default: value)
#
# SPDX-License-Identifier: MIT

set -eu

PLUGIN_NAME="plugin_name"

# --- autoconf ---
if [ "${1:-}" = "autoconf" ]; then
    if command -v required_command >/dev/null 2>&1; then
        echo "yes"
    else
        echo "no (reason)"
    fi
    exit 0
fi

# --- config ---
if [ "${1:-}" = "config" ]; then
    cat <<'EOF'
graph_title Plugin Title
graph_args --base 1000 -l 0
graph_vlabel Units
graph_category category
graph_info Description of what this graph shows.
metric.label Metric Name
metric.draw LINE2
metric.colour 0088ff
metric.info Description of the metric.
EOF
    exit 0
fi

# --- fetch ---
# Gather and print metrics
echo "metric.value 0"
```

### Requirements

1. **Shebang**: Use `#!/bin/sh` (POSIX) or `#!/bin/bash`
2. **Autoconf**: Must respond to `autoconf` with `yes` or `no`
3. **Config**: Must respond to `config` with valid Munin graph definition
4. **Metrics**: Must output `.value` lines in normal mode
5. **Error handling**: Output `U` for unavailable values
6. **Executable**: File must have execute permission
7. **SPDX header**: Include license identifier
8. **Comments**: Document all config variables and behavior

### Shell Standards

- Follow ShellCheck recommendations
- Prefer POSIX-compatible constructs
- Quote all variable expansions
- Avoid useless use of cat
- Avoid unnecessary subshells
- Use meaningful variable names
- Handle errors gracefully

### Testing Your Plugin

1. Run ShellCheck:
   ```bash
   shellcheck --severity=warning --shell=sh plugins/category/your_plugin
   ```

2. Test config output:
   ```bash
   ./plugins/category/your_plugin config
   ```

3. Test autoconf:
   ```bash
   ./plugins/category/your_plugin autoconf
   ```

4. Run full test suite:
   ```bash
   make test
   ```

### Adding Example Configuration

Add Munin configuration examples to `examples/munin-plugin-conf.d`:

```ini
[your_plugin]
# env.your_variable value
user nobody
```

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(docker): add container restart tracking
fix(security): handle missing journalctl gracefully
docs: update installation instructions
test: add config validation for new plugin
ci: update GitHub Actions workflow
chore: update dependencies
```

### Scope Values

Use the directory name as scope: `docker`, `security`, `disk`, `network`, `system`, `backup`, `kubernetes`, `web`, `qdrant`, `api`, `docs`, `ci`, `test`.

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes
3. Run `make test && make lint` — all must pass
4. Write a clear PR description
5. Wait for review
6. Address feedback

## Coding Style

- Use 4-space indentation (no tabs)
- Maximum line length: 100 characters
- Comment complex logic
- Use `$(command)` instead of backticks
- Use `printf '%s\n'` over `echo` when precise control is needed
- Always quote variables: `"$var"` not `$var`

## Reporting Bugs

Use GitHub Issues with:

1. Plugin name and version
2. Operating system and version
3. Munin version
4. Expected behavior
5. Actual behavior (including output)
6. Steps to reproduce

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
