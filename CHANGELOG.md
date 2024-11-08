# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial plugin collection with 15 Munin plugins
- Docker plugins: container monitor, image stats, disk usage
- Security plugins: SSH failed login, firewall monitor, SSL certificate expiry
- Disk plugin: SMART temperature monitoring
- Web plugins: Nginx status, REST API health
- Network plugin: internet latency with packet loss
- System plugin: CPU temperature
- Backup plugin: backup age monitoring
- Kubernetes plugin: pod status tracking
- Database plugin: Qdrant vector DB monitor
- Log plugin: configurable pattern-based log monitoring
- Example Munin configuration files
- Shell-based test suite with config/metric validation
- Makefile with install, test, lint, and package targets
- GitHub Actions CI workflows (ShellCheck, tests, markdown lint)
- Comprehensive documentation suite
- Setup helper script for easy installation

## [1.0.0] - 2024-12-01

### Added
- Docker container status monitoring (running, stopped, restarting, paused)
- Docker image statistics (total, dangling, size)
- Docker disk usage breakdown (images, containers, volumes, build cache)
- SSH failed login detection (failed, invalid user, root attempts)
- Firewall packet monitoring (iptables and nftables support)
- SSL certificate expiration tracking with configurable hosts
- SMART disk temperature monitoring with auto-detection
- Nginx stub_status connection monitoring
- REST API health endpoint monitoring (response time, status, availability)
- Backup age monitoring with newest/oldest/count metrics
- Internet latency monitoring with configurable ping targets
- CPU temperature monitoring (lm-sensors and sysfs)
- Kubernetes pod phase monitoring (running, pending, failed, completed, CrashLoopBackOff)
- Qdrant vector database metrics monitoring
- Configurable log pattern monitoring plugin
- autoconf support for all plugins
- suggest support where applicable
- Error handling with U values for missing data
- SPDX license headers on all files

[Unreleased]: https://github.com/your-org/munin-plugin-pack/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/your-org/munin-plugin-pack/releases/tag/v1.0.0
