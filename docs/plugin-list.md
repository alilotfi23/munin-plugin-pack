# Plugin List

Complete list of all plugins included in munin-plugin-pack, organized by category.

## Docker

### docker_containers
Monitor Docker container status counts.

| Metric     | Description                           |
|------------|---------------------------------------|
| running    | Number of running containers          |
| stopped    | Number of stopped containers          |
| restarting | Number of containers in restart loop |
| paused     | Number of paused containers          |

**Requirements**: Docker CLI  
**Config**: `docker_host` (default: `unix:///var/run/docker.sock`)

---

### docker_images
Track Docker image statistics.

| Metric          | Description                              |
|-----------------|------------------------------------------|
| total_images    | Total number of Docker images            |
| dangling_images | Number of untagged/dangling images       |
| total_size      | Total disk usage in GB                   |

**Requirements**: Docker CLI  
**Config**: `docker_host`

---

### docker_disk_usage
Monitor Docker disk usage breakdown.

| Metric       | Description                   |
|--------------|-------------------------------|
| images       | Disk space used by images     |
| containers  | Disk space used by containers |
| volumes      | Disk space used by volumes    |
| build_cache  | Disk space used by build cache|

**Requirements**: Docker CLI  
**Config**: `docker_host`

---

## Security

### ssh_failed_logins
Monitor SSH authentication failures from system logs.

| Metric        | Description                        |
|---------------|------------------------------------|
| failed        | Failed login attempts              |
| invalid       | Invalid username attempts          |
| root          | Direct root login attempts         |

**Requirements**: journalctl or `/var/log/auth.log`  
**Config**: `auth_log`, `time_range`

---

### firewall_monitor
Monitor iptables/nftables packet counters.

| Metric   | Description                    |
|----------|--------------------------------|
| dropped  | Dropped packet count           |
| rejected | Rejected packet count          |
| accepted | Accepted packet count          |

**Requirements**: iptables or nft  
**Config**: `firewall_type` (iptables/nftables)

---

### ssl_cert_expiry
Track SSL certificate expiration for configured hosts.

| Metric (per host) | Description                   |
|--------------------|-------------------------------|
| hostname_port      | Days until certificate expiry |

**Requirements**: openssl  
**Config**: `ssl_hosts` (space-separated `host:port` pairs)

---

## Disk

### smart_temperature
Monitor disk temperature via S.M.A.R.T.

| Metric (per disk) | Description               |
|--------------------|---------------------------|
| device_name        | Temperature in Celsius    |

**Requirements**: smartmontools (smartctl)  
**Config**: `smart_devices`, `warn_temp`, `crit_temp`  
**Symlink**: `smart_temp_sda`, `smart_temp_sdb`, etc.

---

## Web

### nginx_status
Monitor Nginx stub_status metrics.

| Metric   | Description                          |
|----------|--------------------------------------|
| active   | Active connections                   |
| reading  | Connections reading request headers  |
| writing  | Connections writing response data    |
| waiting  | Idle keepalive connections            |

**Requirements**: curl/wget, Nginx stub_status module  
**Config**: `nginx_status_url`, `nginx_user`, `nginx_password`

---

### api_health
Monitor REST API health endpoint.

| Metric        | Description              |
|---------------|--------------------------|
| response_time | Response time in ms      |
| http_status   | HTTP status code         |
| availability   | 1=up, 0=down             |

**Requirements**: curl  
**Config**: `api_url`, `api_timeout`, `api_expect`, `api_method`

---

## Backup

### backup_age
Monitor backup directory freshness.

| Metric       | Description                     |
|--------------|---------------------------------|
| newest_age   | Age of newest backup (hours)   |
| oldest_age   | Age of oldest backup (hours)   |
| backup_count | Total number of backups        |

**Requirements**: find, stat  
**Config**: `backup_dir`, `backup_pattern`, `backup_max_age`, `backup_crit_age`

---

## Network

### latency
Measure network latency and packet loss via ICMP ping.

| Metric (per host) | Description          |
|--------------------|----------------------|
| host_latency       | Round-trip time (ms) |
| host_loss          | Packet loss (%)      |

**Requirements**: ping  
**Config**: `ping_hosts`, `ping_count`, `ping_timeout`

---

## System

### cpu_temperature
Monitor CPU temperature.

| Metric      | Description                |
|-------------|----------------------------|
| temperature | CPU temperature in Celsius |

**Requirements**: lm-sensors or /sys/class/thermal  
**Config**: `temp_source`, `temp_zone`, `warn_temp`, `crit_temp`

---

## Kubernetes

### k8s_pods
Monitor Kubernetes pod phases.

| Metric            | Description                  |
|-------------------|------------------------------|
| running           | Running pods                 |
| pending           | Pending pods                 |
| failed            | Failed pods                  |
| completed         | Completed pods (Succeeded)   |
| crashloopbackoff  | CrashLoopBackOff pods        |

**Requirements**: kubectl  
**Config**: `kubectl_context`, `kubectl_namespace`

---

## Database

### qdrant_monitor
Monitor Qdrant vector database metrics.

| Metric      | Description                   |
|-------------|-------------------------------|
| collections | Number of collections         |
| vectors     | Total indexed vectors         |
| requests    | Total API requests            |
| memory      | RSS memory usage (bytes)      |
| uptime      | Process uptime (seconds)     |

**Requirements**: curl  
**Config**: `qdrant_url`, `qdrant_timeout`

---

## Logs

### log_monitor
Generic configurable log pattern monitor.

| Metric (per rule) | Description                   |
|--------------------|-------------------------------|
| file_pattern_count | Pattern match count           |

**Requirements**: grep  
**Config**: `log_monitor_config` (path to rule file), `log_monitor_window`

**Rule file format**: `logfile|pattern` (one per line)
