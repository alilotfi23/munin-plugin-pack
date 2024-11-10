# Plugin Development Guide

This guide covers how to develop Munin plugins for the munin-plugin-pack project.

## Munin Plugin Basics

A Munin plugin is an executable script that Munin-node calls with specific arguments:

| Argument    | Purpose                                          |
|-------------|--------------------------------------------------|
| (none)      | Fetch and print current metric values            |
| `config`    | Print graph configuration (titles, labels, etc.) |
| `autoconf`  | Report whether the plugin can run on this system |
| `suggest`   | (Optional) Suggest available plugin instances    |

### Output Format

#### Config Output

```text
graph_title CPU Temperature
graph_args --base 1000 -l 0
graph_vlabel Celsius
graph_category system
graph_info Current CPU temperature reading.

temperature.label CPU Temp
temperature.draw LINE2
temperature.colour ff4400
temperature.warning 70
temperature.critical 85
temperature.info CPU temperature in degrees Celsius.
```

#### Metric Output

```text
temperature.value 42.5
```

Use `U` for unavailable values:
```text
temperature.value U
```

## Key Configuration Directives

| Directive         | Description                                        |
|-------------------|----------------------------------------------------|
| `graph_title`     | Title of the graph                                 |
| `graph_args`      | Graph arguments (e.g., `--base 1000 -l 0`)         |
| `graph_vlabel`    | Y-axis label                                       |
| `graph_category`  | Category for grouping in Munin UI                  |
| `graph_info`      | Description shown on hover in Munin UI             |
| `metric.label`    | Label for a data series                            |
| `metric.draw`      | Drawing method: LINE1, LINE2, AREA, STACK         |
| `metric.colour`    | Hex colour code                                    |
| `metric.type`      | GAUGE (default), DERIVE, COUNTER, ABSOLUTE        |
| `metric.warning`   | Warning threshold                                  |
| `metric.critical`  | Critical threshold                                 |
| `metric.info`      | Description for this metric                        |

## Plugin Template

```sh
#!/bin/sh
# munin-plugin-pack: Plugin Name
# Brief description.
#
# Requirements: list of external tools needed
# Config variables:
#   var_name - Description (default: value)
#
# SPDX-License-Identifier: MIT

set -eu

PLUGIN_NAME="my_plugin"
VAR="${var_name:-default_value}"

# --- autoconf ---
if [ "${1:-}" = "autoconf" ]; then
    if command -v required_cmd >/dev/null 2>&1; then
        echo "yes"
    else
        echo "no (required_cmd not found)"
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
graph_info What this plugin monitors.
metric.label Metric Name
metric.draw LINE2
metric.colour 0088ff
metric.info Description of this metric.
EOF
    exit 0
fi

# --- fetch ---
if ! command -v required_cmd >/dev/null 2>&1; then
    echo "metric.value U"
    exit 0
fi

value=$(some_command_to_get_value 2>/dev/null)
echo "metric.value ${value:-U}"
```

## Multi-Instance Plugins

Plugins that monitor multiple targets should use symlinks or configuration:

### Approach 1: Configuration Variable

```sh
# Plugin reads targets from environment variable
TARGETS="${my_targets:-default1 default2}"
```

### Approach 2: Symlink Naming

```sh
# Plugin name encodes the target
basename=$(basename "$0")
case "$basename" in
    my_plugin_*) target="${basename#my_plugin_}" ;;
esac
```

### Approach 3: suggest() Method

```sh
if [ "${1:-}" = "suggest" ]; then
    # List all possible instances
    for item in /path/to/targets/*; do
        echo "my_plugin_$(basename "$item")"
    done
    exit 0
fi
```

## Graph Drawing Methods

| Method  | Description                             |
|---------|-----------------------------------------|
| LINE1   | Thin line                                |
| LINE2   | Normal line (recommended)               |
| LINE3   | Thick line                               |
| AREA    | Filled area (good for totals)           |
| STACK   | Stacked area (adds to previous metric)  |

## Metric Types

| Type     | Description                                        |
|----------|----------------------------------------------------|
| GAUGE    | Current value (e.g., temperature, count)          |
| DERIVE   | Rate of change per second (e.g., packets/sec)      |
| COUNTER  | Monotonically increasing counter                    |
| ABSOLUTE | Like DERIVE but resets to 0 on restart              |

## Colour Palette

Recommended colours for consistency across plugins:

| Colour   | Usage                         |
|----------|-------------------------------|
| 0088ff   | Primary metric / info         |
| 00cc00   | Success / OK / accepted       |
| ff0000   | Error / danger / failed       |
| ff4400   | Warning / temperature        |
| ffaa00   | Caution / pending             |
| ff6600   | Secondary warning             |
| cc00cc   | Tertiary / memory / waiting   |
| ff00ff   | CrashLoop / special           |
| 00ff00   | Running / available           |
| ff8800   | Writing / in-progress        |

## Error Handling Best Practices

1. **Always check dependencies before use**:
   ```sh
   if ! command -v docker >/dev/null 2>&1; then
       echo "metric.value U"
       exit 0
   fi
   ```

2. **Use default values**:
   ```sh
   value=$(some_command 2>/dev/null)
   echo "metric.value ${value:-0}"
   ```

3. **Never crash** — always output something:
   ```sh
   if [ -z "$result" ]; then
       echo "metric.value U"
   else
       echo "metric.value $result"
   fi
   ```

4. **Redirect stderr** to prevent Munin-node errors:
   ```sh
   output=$(command 2>/dev/null)
   ```

## Testing Your Plugin

```bash
# Test config output
./your_plugin config

# Test data fetch
./your_plugin

# Test autoconf
./your_plugin autoconf

# Run ShellCheck
shellcheck --severity=warning --shell=sh your_plugin

# Run full test suite
make test
```

## Debugging

Enable Munin-node debug mode:

```bash
# Run plugin directly with munin-run
munin-run your_plugin

# With config
munin-run your_plugin config

# Check Munin-node logs
journalctl -u munin-node -f
```
