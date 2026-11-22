#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root.' >&2; exit 1; }
echo 'This removes only the UDP Custom service and its executable.'
read -r -p 'Keep /root/udp/config.json and backups? [Y/n] ' keep
systemctl disable --now udp-custom.service 2>/dev/null || true
rm -f /etc/systemd/system/udp-custom.service
systemctl daemon-reload
if [[ "$keep" =~ ^[Nn]$ ]]; then rm -rf -- /root/udp; else rm -f /root/udp/udp-custom; fi
echo 'UDP Custom removed.'
