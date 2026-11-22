#!/usr/bin/env bash
set -u
SCRIPT_PATH="$(readlink -f "$0")"
ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
if [[ -r /etc/ssh-one/config.env ]]; then . /etc/ssh-one/config.env; fi
SERVICE_NAME="${UDP_CUSTOM_SERVICE:-udp-custom}"
while true; do
  clear 2>/dev/null || true
  printf '%s\n' 'UDP CUSTOM MENU' '────────────────────────────────────────' \
    '1. Install / repair UDP Custom' '2. Start' '3. Stop' '4. Restart' '5. Status' '6. Uninstall UDP Custom' '0. Back to main menu'
  read -r -p 'Select: ' choice
  case "$choice" in
    1) bash "$ROOT/udp/install.sh"; read -r -p 'Press Enter to continue...' _ ;;
    2) systemctl start "$SERVICE_NAME"; read -r -p 'Press Enter to continue...' _ ;;
    3) systemctl stop "$SERVICE_NAME"; read -r -p 'Press Enter to continue...' _ ;;
    4) systemctl restart "$SERVICE_NAME"; read -r -p 'Press Enter to continue...' _ ;;
    5) systemctl --no-pager --full status "$SERVICE_NAME" || true; read -r -p 'Press Enter to continue...' _ ;;
    6) bash "$ROOT/udp/uninstall.sh"; read -r -p 'Press Enter to continue...' _ ;;
    0) exit 0 ;;
    *) echo 'Invalid option'; sleep 1 ;;
  esac
done
