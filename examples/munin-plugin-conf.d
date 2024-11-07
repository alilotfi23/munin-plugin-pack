# Munin plugin configuration examples for munin-plugin-pack
# Copy the relevant sections to /etc/munin/munin.conf or /etc/munin/plugin-conf.d/

# =============================================
# Docker Plugins
# =============================================

[docker_containers]
user root
env.docker_host unix:///var/run/docker.sock

[docker_images]
user root
env.docker_host unix:///var/run/docker.sock

[docker_disk_usage]
user root
env.docker_host unix:///var/run/docker.sock

# =============================================
# Security Plugins
# =============================================

[ssh_failed_logins]
user root
env.time_range since 1 hour ago

[firewall_monitor]
user root
# env.firewall_type iptables
# env.firewall_type nftables

[ssl_cert_expiry]
# env.ssl_hosts "example.com:443 api.example.com:443 cdn.example.com:443"
user nobody

# =============================================
# Disk Plugins
# =============================================

[smart_temperature]
user root
# env.smart_devices "/dev/sda /dev/sdb"
env.warn_temp 45
env.crit_temp 55

# Per-device symlinks:
#   ln -s /path/to/smart_temperature /etc/munin/plugins/smart_temp_sda
#   ln -s /path/to/smart_temperature /etc/munin/plugins/smart_temp_sdb

# =============================================
# Web / API Plugins
# =============================================

[nginx_status]
# env.nginx_status_url http://localhost:80/nginx_status
# env.nginx_status_url http://localhost:8080/server-status
# env.nginx_user admin
# env.nginx_password secret

[api_health]
# env.api_url http://localhost:8080/health
# env.api_timeout 5
# env.api_expect 200
# env.api_method GET

# =============================================
# Backup Plugins
# =============================================

[backup_age]
# env.backup_dir /var/backups
# env.backup_pattern "*.tar.gz"
# env.backup_max_age 48
# env.backup_crit_age 72

# =============================================
# Network Plugins
# =============================================

[latency]
# env.ping_hosts "8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9"
# env.ping_count 5
# env.ping_timeout 2

# =============================================
# System Plugins
# =============================================

[cpu_temperature]
# env.temp_source sysfs
# env.temp_zone 0
# env.warn_temp 70
# env.crit_temp 85

# =============================================
# Kubernetes Plugins
# =============================================

[k8s_pods]
user nobody
# env.kubectl_context my-cluster
# env.kubectl_namespace default

# =============================================
# Qdrant Plugin
# =============================================

[qdrant_monitor]
# env.qdrant_url http://localhost:6333/metrics
# env.qdrant_timeout 5

# =============================================
# Log Monitor Plugin
# =============================================

[log_monitor]
user root
# env.log_monitor_config /etc/munin/log-monitor.conf
# env.log_monitor_window 1000
