#!/bin/bash

# ─── CONFIG ───────────────────────────────
EMAIL="baridepranali26@gmail.com"
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85
LOG_FILE="/var/log/health_monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# ─── FUNCTIONS ────────────────────────────

check_cpu() {
  CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1)
  if [ "$CPU" -gt "$CPU_THRESHOLD" ]; then
    echo "[$DATE] WARNING: CPU usage is ${CPU}%" >> $LOG_FILE
    #echo "ALERT: CPU usage is ${CPU}% on $(hostname)" | mail -s "CPU Alert" $EMAIL
  else
    echo "[$DATE] OK: CPU usage is ${CPU}%" >> $LOG_FILE
  fi
}

check_memory() {
  MEM=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
  if [ "$MEM" -gt "$MEM_THRESHOLD" ]; then
    echo "[$DATE] WARNING: Memory usage is ${MEM}%" >> $LOG_FILE
    #echo "ALERT: Memory usage is ${MEM}% on $(hostname)" | mail -s "Memory Alert" $EMAIL
  else
    echo "[$DATE] OK: Memory usage is ${MEM}%" >> $LOG_FILE
  fi
}

check_disk() {
  DISK=$(df / | grep / | awk '{print $5}' | sed 's/%//')
  if [ "$DISK" -gt "$DISK_THRESHOLD" ]; then
    echo "[$DATE] WARNING: Disk usage is ${DISK}%" >> $LOG_FILE
    #echo "ALERT: Disk usage is ${DISK}% on $(hostname)" | mail -s "Disk Alert" $EMAIL
  else
    echo "[$DATE] OK: Disk usage is ${DISK}%" >> $LOG_FILE
  fi
}

check_services() {
  SERVICES=("sshd" "crond")
  for SERVICE in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $SERVICE; then
      echo "[$DATE] OK: $SERVICE is running" >> $LOG_FILE
    else
      echo "[$DATE] WARNING: $SERVICE is DOWN" >> $LOG_FILE
      #echo "ALERT: $SERVICE is down on $(hostname)" | mail -s "Service Alert" $EMAIL
    fi
  done
}


check_ssh_intrusion() {
  FAILED=$(grep "Failed password" /var/log/secure 2>/dev/null | wc -l)
  echo "[$DATE] INFO: Failed SSH login attempts: $FAILED" >> $LOG_FILE
  if [ "$FAILED" -gt 10 ]; then
    echo "[$DATE] WARNING: High SSH intrusion attempts: $FAILED" >> $LOG_FILE
  fi
}

# ─── MAIN ─────────────────────────────────
echo "[$DATE] ── Health Check Started ──" >> $LOG_FILE
check_cpu
check_memory
check_disk
check_services
check_ssh_intrusion
echo "[$DATE] ── Health Check Complete ──" >> $LOG_FILE
