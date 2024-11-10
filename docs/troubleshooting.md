# Troubleshooting Guide

Common issues and solutions for munin-plugin-pack plugins.

## General Issues

### Plugin shows "U" values (unknown)

**Cause**: A dependency is missing or unreachable.

**Solution**:
```bash
# Test the plugin directly
./plugin_name

# Check autoconf output
./plugin_name autoconf

# Common missing dependencies
which docker curl openssl ping smartctl sensors kubectl nft iptables
```

### Plugin not showing in Munin web interface

**Cause**: Plugin not enabled in Munin-node.

**Solution**:
```bash
# Enable the plugin
sudo munin-node-configure --shell | sh

# Or create symlink manually
sudo ln -s /usr/share/munin/plugins/docker_containers /etc/munin/plugins/docker_containers

# Restart Munin-node
sudo systemctl restart munin-node

# Verify plugin is recognized
sudo munin-node-configure | grep docker_containers
```

### Permission denied errors

**Cause**: Plugin lacks permissions to access required resources.

**Solution**:
```bash
# Check Munin-node logs
journalctl -u munin-node -n 50

# Grant permissions via plugin-conf.d
# /etc/munin/plugin-conf.d/munin-plugin-pack
[docker_containers]
user root
```

### Munin-node won't start after adding plugins

**Cause**: Plugin has syntax error or crashes on startup.

**Solution**:
```bash
# Run each plugin manually to check for errors
for plugin in /etc/munin/plugins/*; do
    echo "Testing $plugin..."
    "$plugin" config 2>&1 | head -5
done

# Check for non-executable files
ls -la /etc/munin/plugins/
```

## Docker Plugins

### "cannot connect to docker daemon"

```
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock.
```

**Solution**:
```bash
# Ensure Docker is running
sudo systemctl status docker

# Ensure munin-node user has Docker access
sudo usermod -aG docker munin

# Or configure the plugin to use TCP
env.docker_host tcp://127.0.0.1:2375
```

### Docker commands are slow

**Cause**: Large number of images or containers.

**Solution**: Munin-node has a default timeout of 5 seconds. Increase it:

```ini
[docker_containers]
timeout 30
```

## Security Plugins

### SSH failed logins shows 0

**Cause**: Log file location incorrect or no recent failures.

**Solution**:
```bash
# Verify log file location
ls -la /var/log/auth.log
# or
journalctl -u sshd --since "1 hour ago"

# Set explicit path
env.auth_log /var/log/auth.log

# Check for log rotation
ls -la /var/log/auth.log*
```

### Firewall monitor shows all zeros

**Cause**: No rules with DROP/REJECT/ACCEPT counters, or wrong firewall type.

**Solution**:
```bash
# Verify iptables rules exist
sudo iptables -L -nv

# Or nftables
sudo nft list ruleset

# Force the correct type
env.firewall_type nftables
```

### SSL certificate check fails

**Cause**: OpenSSL cannot connect, SNI issues, or self-signed cert.

**Solution**:
```bash
# Test manually
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -noout -enddate

# For self-signed certs, you may need to adjust the openssl command
# or use -servername flag for SNI
```

## Disk Plugin

### SMART temperature shows "U"

**Cause**: smartctl not installed or not enough permissions.

**Solution**:
```bash
# Install smartmontools
sudo apt install smartmontools    # Debian/Ubuntu
sudo dnf install smartmontools    # RHEL/Fedora

# Test manually
sudo smartctl -A /dev/sda

# Ensure user has access
sudo usermod -aG disk munin

# For NVMe drives
sudo smartctl -A /dev/nvme0
```

### "smartctl not found"

**Solution**:
```bash
sudo apt install smartmontools
```

## Web Plugins

### Nginx status returns empty

**Cause**: stub_status module not enabled or URL is incorrect.

**Solution**:
```bash
# Test the URL manually
curl http://localhost/nginx_status

# Verify Nginx config
nginx -t

# Ensure the location block exists:
# location /nginx_status {
#     stub_status on;
#     allow 127.0.0.1;
#     deny all;
# }
```

### API health shows U for all values

**Cause**: Endpoint unreachable or timeout too short.

**Solution**:
```bash
# Test manually
curl -v http://localhost:8080/health

# Increase timeout
env.api_timeout 10

# Check if endpoint exists
curl -o /dev/null -w "%{http_code}" http://localhost:8080/health
```

## Network Plugin

### Latency shows "U" for all hosts

**Cause**: ping command missing or ICMP blocked by firewall.

**Solution**:
```bash
# Install iputils
sudo apt install iputils-ping

# Test manually
ping -c 3 8.8.8.8

# If ICMP is blocked, check firewall rules
sudo iptables -L OUTPUT -nv
```

## System Plugin

### CPU temperature shows "U"

**Cause**: No thermal sensor support or lm-sensors not configured.

**Solution**:
```bash
# Check sysfs thermal zones
cat /sys/class/thermal/thermal_zone*/temp

# Or install and configure lm-sensors
sudo apt install lm-sensors
sudo sensors-detect
sensors

# Force sysfs source
env.temp_source sysfs
```

## Kubernetes Plugin

### k8s_pods shows "U" for all values

**Cause**: kubectl not configured or cluster unreachable.

**Solution**:
```bash
# Verify kubectl works
kubectl cluster-info
kubectl get pods --all-namespaces

# Check kubeconfig
kubectl config view

# Set context explicitly
env.kubectl_context my-cluster
```

## Qdrant Plugin

### Qdrant monitor returns no data

**Cause**: Qdrant not running or metrics endpoint not enabled.

**Solution**:
```bash
# Verify Qdrant is running
curl http://localhost:6333/collections

# Check metrics endpoint
curl http://localhost:6333/metrics

# Enable metrics if needed (check Qdrant config)
```

## Log Monitor Plugin

### log_monitor shows no metrics

**Cause**: Configuration file missing or incorrect format.

**Solution**:
```bash
# Verify config file exists
ls -la /etc/munin/log-monitor.conf

# Check format (must be: logfile|pattern)
cat /etc/munin/log-monitor.conf

# Ensure log files are readable
sudo -u munin head /var/log/auth.log

# Test a pattern manually
tail -100 /var/log/auth.log | grep -c "Failed password"
```

## Debugging Tips

### Run plugin with debug output

```bash
# Add set -x at the top of the plugin temporarily, or:
bash -x ./plugin_name
```

### Check Munin-node communication

```bash
# Test via telnet
telnet localhost 4949
fetch docker_containers
quit

# Or via munin-run
sudo munin-run docker_containers
```

### Monitor Munin-node logs

```bash
# systemd
journalctl -u munin-node -f

# Or log file
tail -f /var/log/munin/munin-node.log
```

### Check Munin cron

```bash
# Ensure Munin master cron is running
sudo crontab -l | grep munin

# Check Munin log
tail -f /var/log/munin/munin-update.log
```
