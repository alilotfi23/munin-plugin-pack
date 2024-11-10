# Configuration Reference

Complete configuration reference for all munin-plugin-pack plugins.

## Installation Methods

### Method 1: Copy Plugins

```bash
# Copy all plugins to Munin's plugin directory
sudo cp plugins/* /usr/share/munin/plugins/

# Or use the Makefile
sudo make install
```

### Method 2: Symlinks

```bash
# Create symlinks (easier for updates)
for plugin in plugins/*; do
    sudo ln -s "$(pwd)/$plugin" /usr/share/munin/plugins/$(basename "$plugin")
done

# Or use the helper script
./scripts/setup.sh link
```

### Method 3: Clone Directly

```bash
sudo git clone https://github.com/your-org/munin-plugin-pack.git /opt/munin-plugin-pack
for plugin in /opt/munin-plugin-pack/plugins/*; do
    sudo ln -s "$plugin" /usr/share/munin/plugins/$(basename "$plugin")
done
```

## Enabling Plugins

After installing, enable plugins in Munin-node:

```bash
# Enable individual plugins
sudo munin-node-configure --shell | sh

# Or manually symlink
sudo ln -s /usr/share/munin/plugins/docker_containers /etc/munin/plugins/docker_containers
```

Restart Munin-node after enabling:

```bash
sudo systemctl restart munin-node
```

## Munin Plugin Configuration

Plugin configuration goes in `/etc/munin/plugin-conf.d/` or `/etc/munin/munin.conf`.

### Using plugin-conf.d (recommended)

Create a file per plugin or group:

```bash
# /etc/munin/plugin-conf.d/munin-plugin-pack
[docker_containers]
user root
env.docker_host unix:///var/run/docker.sock

[ssl_cert_expiry]
env.ssl_hosts "example.com:443 api.example.com:443"
```

### Using munin.conf (legacy)

Add plugin config sections in the host block:

```ini
[server.example.com]
    address 127.0.0.1
    use_node_name yes

    [server.example.com;docker_containers]
        user root
        env.docker_host unix:///var/run/docker.sock
```

## Plugin Configuration Variables

### Docker Plugins

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| docker_containers | `docker_host` | `unix:///var/run/docker.sock` | Docker daemon socket URI |
| docker_images | `docker_host` | `unix:///var/run/docker.sock` | Docker daemon socket URI |
| docker_disk_usage | `docker_host` | `unix:///var/run/docker.sock` | Docker daemon socket URI |

### Security Plugins

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| ssh_failed_logins | `auth_log` | auto-detect | Path to auth log file |
| ssh_failed_logins | `time_range` | `since 1 hour ago` | journalctl time range |
| firewall_monitor | `firewall_type` | auto-detect | Force `iptables` or `nftables` |
| ssl_cert_expiry | `ssl_hosts` | `localhost:443` | Space-separated host:port pairs |

### Disk Plugin

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| smart_temperature | `smart_devices` | auto-detect | Space-separated device paths |
| smart_temperature | `warn_temp` | `45` | Warning threshold (°C) |
| smart_temperature | `crit_temp` | `55` | Critical threshold (°C) |

### Web Plugins

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| nginx_status | `nginx_status_url` | `http://localhost:80/nginx_status` | Nginx stub_status URL |
| nginx_status | `nginx_user` | (none) | Basic auth username |
| nginx_status | `nginx_password` | (none) | Basic auth password |
| api_health | `api_url` | `http://localhost:8080/health` | Health endpoint URL |
| api_health | `api_timeout` | `5` | Request timeout (seconds) |
| api_health | `api_expect` | `200` | Expected HTTP status code |
| api_health | `api_method` | `GET` | HTTP method |

### Backup Plugin

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| backup_age | `backup_dir` | `/var/backups` | Backup directory path |
| backup_age | `backup_pattern` | `*` | File glob pattern |
| backup_age | `backup_max_age` | `48` | Warning threshold (hours) |
| backup_age | `backup_crit_age` | `72` | Critical threshold (hours) |

### Network Plugin

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| latency | `ping_hosts` | `8.8.8.8 1.1.1.1` | Space-separated hosts |
| latency | `ping_count` | `5` | Pings per host |
| latency | `ping_timeout` | `2` | Timeout per ping (seconds) |

### System Plugin

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| cpu_temperature | `temp_source` | auto-detect | `sysfs` or `sensors` |
| cpu_temperature | `temp_zone` | `0` | Thermal zone number (sysfs) |
| cpu_temperature | `warn_temp` | `70` | Warning threshold (°C) |
| cpu_temperature | `crit_temp` | `85` | Critical threshold (°C) |

### Kubernetes Plugin

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| k8s_pods | `kubectl_context` | current | Kubernetes context |
| k8s_pods | `kubectl_namespace` | (all) | Namespace to monitor |

### Qdrant Plugin

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| qdrant_monitor | `qdrant_url` | `http://localhost:6333/metrics` | Metrics endpoint URL |
| qdrant_monitor | `qdrant_timeout` | `5` | Request timeout (seconds) |

### Log Monitor Plugin

| Plugin | Variable | Default | Description |
|--------|----------|---------|-------------|
| log_monitor | `log_monitor_config` | `/etc/munin/log-monitor.conf` | Rule file path |
| log_monitor | `log_monitor_window` | `1000` | Lines to scan per file |

## Log Monitor Rule File Format

The log monitor configuration file (`/etc/munin/log-monitor.conf`) uses a simple format:

```
# Comment lines start with #
logfile|pattern
```

Each line defines:
- **logfile**: Absolute path to the log file
- **pattern**: grep-compatible pattern to match

Examples:
```
/var/log/auth.log|Failed password
/var/log/auth.log|Invalid user
/var/log/nginx/error.log|500
/var/log/nginx/error.log|502
/var/log/app/app.log|panic
/var/log/syslog|Out of memory
```

## Nginx Configuration

Enable the stub_status module in Nginx:

```nginx
server {
    listen 80;
    server_name localhost;

    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        allow ::1;
        deny all;
    }
}
```

Test it:
```bash
curl http://localhost/nginx_status
```

Expected output:
```
Active connections: 5
server accepts handled requests
 1234 1234 5678
Reading: 0 Writing: 1 Waiting: 4
```

## Docker Configuration

If Docker is accessed via TCP instead of a socket:

```ini
[docker_containers]
user root
env.docker_host tcp://127.0.0.1:2375
```

For Docker with TLS:

```ini
[docker_containers]
user root
env.docker_host tcp://127.0.0.1:2376
env.docker_tls_verify 1
env.docker_cert_path /home/user/.docker
```

## Kubernetes Configuration

Ensure kubectl is configured with the correct context:

```bash
# Verify context
kubectl config current-context

# Test cluster access
kubectl cluster-info
```

If using in-cluster config (running on a pod):

```bash
# Install kubectl
# Plugin will use the pod's service account
```
