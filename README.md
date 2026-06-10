# Linux Server Health Monitor

Automated health monitoring system deployed on AWS EC2.

## What it monitors
- CPU utilization (threshold: 80%)
- Memory usage (threshold: 80%)
- Disk usage (threshold: 85%)
- Critical service status (sshd, crond)
- Failed SSH login attempts (intrusion detection)

## Tech Stack
- Bash scripting
- AWS EC2 (Amazon Linux)
- Cron scheduling
- System logging (/var/log)

## How it works
Cron job runs every 5 minutes, checks all metrics,
logs results to /var/log/health_monitor.log,
and sends email alerts when thresholds are breached.
