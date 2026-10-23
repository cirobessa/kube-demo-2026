#!/bin/bash
# Daily backup script - english
set -e
cd /home/ciro/kube-demo-2026
git add -A
git commit -m "daily-backup-$(date +%F)" || true
git push origin main 2>/dev/null || echo "push skipped (no token?)"
echo "Backup done at $(date)"
