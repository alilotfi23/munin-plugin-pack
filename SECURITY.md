# Security Policy

## Supported Versions

Only the latest stable release is actively supported. Backported security fixes may be provided for the previous release on a best-effort basis.

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in this project, please follow these guidelines:

### Do NOT open a public issue

Security vulnerabilities should be reported privately to prevent potential exploitation before a fix is available.

### How to Report

1. **Email**: Send a report to the project maintainers via the GitHub Security Advisories feature.
   - Go to the repository on GitHub
   - Click **Security** > **Advisories** > **Report a vulnerability**
   - Fill in the details

2. **Include in your report**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

3. **Expected response time**: We aim to acknowledge reports within 48 hours and provide a fix within 7 days for critical issues.

### Disclosure Policy

- Once a fix is merged, we will publish a GitHub Security Advisory
- Credit will be given to the reporter (unless anonymity is requested)
- We request that reporters do not publicly disclose the vulnerability until a fix is available

## Security Best Practices for Plugin Users

### File Permissions

Munin plugins run with elevated privileges. Ensure proper permissions:

```bash
# Only root-owned files should be setuid
chmod 755 /usr/share/munin/plugins/*
chown root:root /usr/share/munin/plugins/*
```

### Input Validation

Plugins that accept configuration variables validate input:
- Environment variables are quoted to prevent injection
- File paths are checked before access
- External commands use fixed argument lists

### Network Access

- Plugins only connect to explicitly configured endpoints
- No outbound connections are made without user configuration
- Timeout values are enforced on all network operations

## Plugin-Specific Security Notes

### SSH Failed Login Monitor
- Reads from system logs only
- Does not modify any files
- Requires root access for journalctl/log file access

### Firewall Monitor
- Read-only access to iptables/nftables counters
- Does not modify firewall rules
- Requires root access

### SMART Disk Temperature
- Uses smartctl in read-only mode
- Requires root or disk group membership

### Log Monitor
- Reads log files only, never modifies them
- Pattern matching does not execute shell commands

### SSL Certificate Expiry
- Makes TLS connections to configured hosts only
- Does not store or transmit certificate data

## Acknowledgments

We thank all security researchers who responsibly disclose vulnerabilities to help keep this project secure.
