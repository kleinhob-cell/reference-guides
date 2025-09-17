#!/usr/bin/env bash
# Post-Resize Live Audit Script
# Location: /home/brent/reference-guides/post_resize_live_audit.sh
# Purpose: Verify mounts, swap, and meeting assistant stack health after live partition/disk changes.

set -euo pipefail

LOGDIR="$HOME/reference-guides/logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/post_resize_live_audit_$(date +%F_%H-%M-%S).log"

echo "=== Post-Resize Live Audit ===" | tee "$LOGFILE"
date | tee -a "$LOGFILE"

echo -e "\n[1/6] Filesystem & Mount Table Verification" | tee -a "$LOGFILE"
sudo findmnt --verify --verbose | tee -a "$LOGFILE"

echo -e "\n[2/6] Partition & UUID Map" | tee -a "$LOGFILE"
lsblk -f | tee -a "$LOGFILE"
blkid | tee -a "$LOGFILE"

echo -e "\n[3/6] Swap Status" | tee -a "$LOGFILE"
swapon --show | tee -a "$LOGFILE"
free -h | tee -a "$LOGFILE"

echo -e "\n[4/6] Filesystem State (ext4 volumes)" | tee -a "$LOGFILE"
for dev in $(lsblk -ndo NAME,FSTYPE | awk '$2=="ext4"{print $1}'); do
    sudo tune2fs -l /dev/$dev | grep 'Filesystem state' | tee -a "$LOGFILE"
done

echo -e "\n[5/6] Kernel & Journal Disk Warnings (last 1h)" | tee -a "$LOGFILE"
sudo dmesg | grep -iE 'error|warn|fail|I/O' | tee -a "$LOGFILE" || true
sudo journalctl -k -p err..alert --since "1 hour ago" | tee -a "$LOGFILE" || true

echo -e "\n[6/6] Meeting Assistant Stack Check" | tee -a "$LOGFILE"
PROJECT_DIR="$HOME/ai-assistant-project"

if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    echo "Project path: $PROJECT_DIR" | tee -a "$LOGFILE"

    # Git status
    if [ -d .git ]; then
        git status | tee -a "$LOGFILE"
    else
        echo "No Git repo found in $PROJECT_DIR" | tee -a "$LOGFILE"
    fi

    # Container/service checks
    docker ps | tee -a "$LOGFILE" || true
    docker compose ps | tee -a "$LOGFILE" || true

    # Dry-run meeting assistant if script exists
    if [ -x ./scripts/run-meeting-assistant.sh ]; then
        ./scripts/run-meeting-assistant.sh --dry-run | tee -a "$LOGFILE" || true
    else
        echo "No run-meeting-assistant.sh script found in $PROJECT_DIR/scripts" | tee -a "$LOGFILE"
    fi
else
    echo "Meeting assistant project directory not found at $PROJECT_DIR" | tee -a "$LOGFILE"
fi

echo -e "\n=== Audit Complete ===" | tee -a "$LOGFILE"
echo "Log saved to: $LOGFILE"
