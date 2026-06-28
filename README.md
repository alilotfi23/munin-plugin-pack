# munin-plugin-pack

> Production-ready Munin plugins for monitoring Linux servers, Docker, Kubernetes, networking, security, backups, and applications.

[![ShellCheck](https://github.com/alilotfi23/munin-plugin-pack/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/alilotfi23/munin-plugin-pack/actions/workflows/shellcheck.yml)
[![Plugin Tests](https://github.com/alilotfi23/munin-plugin-pack/actions/workflows/test.yml/badge.svg)](https://github.com/alilotfi23/munin-plugin-pack/actions/workflows/test.yml)
[![Markdown Lint](https://github.com/alilotfi23/munin-plugin-pack/actions/workflows/markdown-lint.yml/badge.svg)](https://github.com/alilotfi23/munin-plugin-pack/actions/workflows/markdown-lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](CHANGELOG.md)

---

## Project Overview

**munin-plugin-pack** is a curated collection of high-quality, production-ready [Munin](https://munin-monitoring.org/) plugins written entirely in POSIX shell. It extends Munin's stock plugin set with monitoring for modern infrastructure: containers, orchestration platforms, vector databases, security events, backups, and application health.

Every plugin is:

- **Dependency-light** — uses only standard Unix tools (`awk`, `grep`, `sed`, `cut`, `tr`, `date`, `find`, `stat`)
- **POSIX-compliant** — runs under `/bin/sh` on any Linux distribution
- **Munin-conformant** — supports `config`, `autoconf`, and `suggest` modes
- **Error-resilient** — returns `U` instead of crashing when data is unavailable
- **Well-documented** — commented source, example configs, and per-plugin docs
- **Tested** — validated by a shell-based test suite and ShellCheck in CI

---

## Features

- **15 plugins** across 10 categories
- **Auto-detection** of system capabilities via `autoconf`
- **Configurable** via standard Munin environment variables
- **Multi-instance support** for SSL certs, latency, and log monitoring
- **Unified colour palette** for consistent graph appearance
- **Zero Python/Perl/Ruby dependencies** — pure shell
- **SPDX-licensed** (MIT) with headers on every file

---

## Supported Operating Systems

| OS | Status | Notes |
|----|--------|-------|
| Debian 11/12 | ✅ Fully supported | Primary test platform |
| Ubuntu 20.04/22.04/24.04 | ✅ Fully supported | |
| RHEL / Rocky / AlmaLinux 8/9 | ✅ Fully supported | |
| Fedora 38+ | ✅ Fully supported | |
| Arch Linux | ✅ Fully supported | |
| Alpine Linux | ⚠️ Works | Some tools need `apk add` |
| macOS | ⚠️ Partial | Munin-node support varies |

**Requirements**: Munin-node 2.0+ installed and running.

---

## Requirements

### Core (all plugins)

- A POSIX-compliant shell (`dash`, `bash`, `ash`)
- Munin-node (`apt install munin-node` or equivalent)
- Standard Unix utilities: `awk`, `grep`, `sed`, `cut`, `tr`, `date`, `find`, `stat`

### Per-plugin dependencies

| Plugin | Required tool(s) |
|--------|------------------|
| `docker_*` | `docker` CLI |
| `ssh_failed_logins` | `journalctl` or `/var/log/auth.log` |
| `firewall_monitor` | `iptables` or `nft` |
| `smart_temperature` | `smartctl` (smartmontools) |
| `nginx_status` | `curl` or `wget` |
| `api_health` | `curl` |
| `backup_age` | `find`, `stat` |
| `latency` | `ping` (iputils) |
| `cpu_temperature` | `sensors` (lm-sensors) or sysfs |
| `k8s_pods` | `kubectl` |
| `qdrant_monitor` | `curl` |
| `ssl_cert_expiry` | `openssl` |
| `log_monitor` | `grep`, `tail` |

---

## Installation

### Option 1: From source (recommended)

```bash
git clone https://github.com/alilotfi23/munin-plugin-pack.git
cd munin-plugin-pack

# Install plugins and docs
sudo make install

# Install example configuration
sudo make install-examples

# Restart Munin-node
sudo systemctl restart munin-node
```

### Option 2: Using the setup helper

```bash
git clone https://github.com/alilotfi23/munin-plugin-pack.git
cd munin-plugin-pack

# Link plugins (easier to update — git pull refreshes them)
sudo ./scripts/setup.sh link

# Or copy them
sudo ./scripts/setup.sh install

# Install configuration examples
sudo ./scripts/setup.sh configure

# Verify everything is set up
sudo ./scripts/setup.sh verify
```

### Option 3: From release tarball

```bash
# Download latest release from GitHub Releases page
wget https://github.com/alilotfi23/munin-plugin-pack/releases/download/v1.0.0/munin-plugin-pack-1.0.0.tar.gz
tar xzf munin-plugin-pack-1.0.0.tar.gz
cd munin-plugin-pack-1.0.0
sudo make install
```

### Enabling individual plugins

```bash
# Auto-detect and enable available plugins
sudo munin-node-configure --shell | sh

# Or enable manually via symlink
sudo ln -s /usr/share/munin/plugins/docker_containers /etc/munin/plugins/docker_containers

# Restart Munin-node to apply
sudo systemctl restart munin-node
```

---

## Directory Layout

```
munin-plugin-pack/
├── plugins/              # Plugin source code (15 plugins)
│   ├── docker/           # Container, image, disk usage monitoring
│   ├── security/         # SSH, firewall, SSL monitoring
│   ├── disk/             # SMART temperature
│   ├── network/          # Latency monitoring
│   ├── system/           # CPU temperature
│   ├── backup/           # Backup age monitoring
│   ├── kubernetes/       # Pod status
│   ├── web/              # Nginx, API health
│   ├── qdrant/           # Qdrant vector DB
│   └── api/              # Generic log monitoring
├── examples/             # Example Munin configuration files
├── docs/                 # Documentation
├── scripts/              # Setup and maintenance helpers
├── tests/                # Test scripts
├── .github/workflows/    # CI pipelines (ShellCheck, tests, release)
├── README.md             # This file
├── CHANGELOG.md          # Release history
├── CONTRIBUTING.md       # How to contribute
├── SECURITY.md           # Security policy
├── CODE_OF_CONDUCT.md    # Community standards
├── LICENSE               # MIT License
└── Makefile              # Build/install/test targets
```

---

## Plugin List

| # | Plugin | Category | Metrics |
|---|--------|----------|---------|
| 1 | `docker_containers` | docker | running, stopped, restarting, paused |
| 2 | `docker_images` | docker | total, dangling, size |
| 3 | `docker_disk_usage` | docker | images, containers, volumes, build cache |
| 4 | `ssh_failed_logins` | security | failed, invalid, root |
| 5 | `firewall_monitor` | security | dropped, rejected, accepted |
| 6 | `ssl_cert_expiry` | security | days remaining (per host) |
| 7 | `smart_temperature` | disk | temperature (per disk) |
| 8 | `nginx_status` | web | active, reading, writing, waiting |
| 9 | `api_health` | web | response time, status, availability |
| 10 | `backup_age` | backup | newest age, oldest age, count |
| 11 | `latency` | network | latency, packet loss (per host) |
| 12 | `cpu_temperature` | system | CPU temperature |
| 13 | `k8s_pods` | kubernetes | running, pending, failed, completed, crashloopbackoff |
| 14 | `qdrant_monitor` | database | collections, vectors, requests, memory, uptime |
| 15 | `log_monitor` | logs | pattern match counts (configurable) |

See [docs/plugin-list.md](docs/plugin-list.md) for detailed metric documentation.

---

## Screenshots

<!-- TODO: Add screenshots of Munin graphs generated by these plugins. -->

*Screenshots of Munin dashboards populated by these plugins will be added here.*

---

## Example Graphs

### Docker Containers
```
Running ████████████████░░░░ 12
Stopped ████░░░░░░░░░░░░░░░░  3
Paused  ░░░░░░░░░░░░░░░░░░░░  0
```

### Internet Latency
```
8.8.8.8   ▆▅▄▆▇▆▅▄▅▆▇▅▄▆▅  5.2 ms avg
1.1.1.1   ▃▄▅▄▃▄▅▄▃▄▅▄▃▄▅▄  4.1 ms avg
```

### CPU Temperature
```
45°C ▁▂▃▄▅▆▇█▇▆▅▄▅▆▇█▇▆▅▄▃▂▁
```

---

## Configuration Examples

### Docker monitoring with root access

```ini
# /etc/munin/plugin-conf.d/docker
[docker_containers]
user root
env.docker_host unix:///var/run/docker.sock

[docker_images]
user root

[docker_disk_usage]
user root
```

### SSL certificate monitoring

```ini
# /etc/munin/plugin-conf.d/ssl
[ssl_cert_expiry]
env.ssl_hosts "example.com:443 api.example.com:443 cdn.example.com:443 mail.example.com:993"
```

### Internet latency to multiple hosts

```ini
# /etc/munin/plugin-conf.d/latency
[latency]
env.ping_hosts "8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9"
env.ping_count 5
env.ping_timeout 2
```

### Log monitoring rules

```bash
# /etc/munin/log-monitor.conf
/var/log/auth.log|Failed password
/var/log/auth.log|Invalid user
/var/log/nginx/error.log|500
/var/log/nginx/error.log|502
/var/log/app/app.log|panic
/var/log/syslog|Out of memory
```

### Nginx stub_status setup

```nginx
# /etc/nginx/sites-enabled/status
server {
    listen 127.0.0.1:80;
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
```

See [docs/configuration.md](docs/configuration.md) for the complete reference.

---

## Development

### Prerequisites

```bash
sudo apt install shellcheck munin-node git make
```

### Running tests locally

```bash
# Run the full test suite
make test

# Lint all shell scripts
make lint

# Run a specific plugin manually
./plugins/docker/docker_containers config
./plugins/docker/docker_containers
```

### Creating a new plugin

1. Use the template in [docs/plugin-development.md](docs/plugin-development.md)
2. Place it in the appropriate `plugins/<category>/` directory
3. Make it executable: `chmod +x plugins/<category>/your_plugin`
4. Add example config to `examples/munin-plugin-conf.d`
5. Run `make test && make lint`
6. Document it in `docs/plugin-list.md`

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

---

## Testing

The test suite (`tests/test-plugins.sh`) validates every plugin for:

- ✅ **Executable permissions** — every plugin must be `chmod +x`
- ✅ **Valid shebang** — must start with `#!/bin/sh` or `#!/bin/bash`
- ✅ **Config output** — must include `graph_title`, `graph_category`, and `.label` definitions
- ✅ **Metric format** — output must match `.value <number|U>` pattern
- ✅ **Autoconf support** — must respond with `yes` or `no`
- ✅ **Security** — no unsafe `/tmp` references
- ✅ **License headers** — SPDX identifier present

Run tests with:

```bash
make test
# or directly
bash tests/test-plugins.sh
```

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

Quick start:

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-new-plugin`
3. Follow [Conventional Commits](https://www.conventionalcommits.org/) for messages
4. Ensure `make test && make lint` pass
5. Open a pull request

By participating, you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md).

---

## Roadmap

### v1.1.0
- [ ] PostgreSQL monitoring plugin
- [ ] Redis monitoring plugin
- [ ] MongoDB monitoring plugin
- [ ] Elasticsearch cluster health plugin

### v1.2.0
- [ ] Prometheus exporter plugin
- [ ] RabbitMQ queue monitoring
- [ ] MySQL slow query tracking
- [ ] Network interface throughput plugin

### v1.3.0
- [ ] Ansible playbook for automated deployment
- [ ] Puppet module
- [ ] Docker image with pre-configured Munin-node

### Future
- [ ] Plugin marketplace / registry
- [ ] Web UI for plugin configuration
- [ ] Auto-generated documentation from plugin metadata
- [ ] BSD/macOS compatibility testing

Vote on features or suggest new ones via [GitHub Issues](https://github.com/alilotfi23/munin-plugin-pack/issues).

---

## FAQ

### Q: Why shell scripts instead of Python/Perl?

**A:** POSIX shell scripts have zero runtime dependencies, run on any Linux system without installation, and start instantly. Munin plugins run frequently (every 5 minutes by default), so avoiding interpreter startup overhead matters. Shell is also the lingua franca of Unix system administration.

### Q: Will these work with Munin 4.x?

**A:** Yes. The plugin protocol (`config`/`autoconf`/fetch) is stable across Munin versions. We test against the current Munin 2.x release.

### Q: How do I monitor multiple Docker hosts?

**A:** Use separate plugin instances with different `env.docker_host` values:

```ini
[docker_containers_host1]
env.docker_host tcp://docker-host1:2376

[docker_containers_host2]
env.docker_host tcp://docker-host2:2376
```

### Q: Why does my plugin show `U` values?

**A:** `U` means "unknown" — a dependency is missing or a service is unreachable. Run the plugin manually to see the error:

```bash
sudo munin-run docker_containers
```

See [docs/troubleshooting.md](docs/troubleshooting.md) for detailed solutions.

### Q: Can I use these with other monitoring systems?

**A:** The plugins output plain text in Munin's format. They can be adapted for Nagios, Zabbix, or custom collectors, but the output format is Munin-specific.

### Q: How often should plugins run?

**A:** Munin's default is every 5 minutes. Plugins are designed to complete within 5 seconds. If a plugin is slow (e.g., many Docker containers), increase the Munin-node timeout.

### Q: Are these plugins safe to run as root?

**A:** Yes. Plugins only read data — they never modify system state. Configuration variables are quoted and validated. See [SECURITY.md](SECURITY.md) for details.

---

## Troubleshooting

Common issues:

| Symptom | Likely cause | Solution |
|---------|-------------|----------|
| Plugin shows `U` | Missing dependency | Run `./plugin autoconf` |
| Not in Munin UI | Plugin not enabled | `sudo munin-node-configure --shell \| sh` |
| Permission denied | Wrong user in config | Add `user root` to plugin config |
| Slow graphs | Munin-node timeout | Increase `timeout` in plugin config |
| Empty output | Service not running | Check the target service |

See [docs/troubleshooting.md](docs/troubleshooting.md) for comprehensive diagnostics.

---

## License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

```
MIT License

Copyright (c) 2024-2026 munin-plugin-pack contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## Acknowledgments

- [Munin Monitoring](https://munin-monitoring.org/) — the project these plugins extend
- The maintainers of [ssm](https://github.com/munin-monitoring/munin) for the plugin protocol spec
- All [contributors](https://github.com/alilotfi23/munin-plugin-pack/graphs/contributors) who improve this pack

---

<p align="center">
  Made with care for the Linux sysadmin community.<br>
  ⭐ Star this repo if it helps you!
</p>
