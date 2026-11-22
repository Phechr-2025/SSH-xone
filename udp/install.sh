#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root.' >&2; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib/project.sh
. "$ROOT/lib/project.sh"
UDP_DIR="${UDP_CUSTOM_ROOT:-/root/udp}"
SERVICE_NAME="${UDP_CUSTOM_SERVICE:-udp-custom}"
SERVICE="/etc/systemd/system/${SERVICE_NAME}.service"
BIN_SOURCE="$ROOT/udp/udp-custom"
CONFIG_SOURCE="$ROOT/udp/config.json"
[[ -s "$BIN_SOURCE" ]] || { echo 'UDP Custom executable is missing.' >&2; exit 1; }
install -d -m 0750 "$UDP_DIR"
install -m 0755 "$BIN_SOURCE" "$UDP_DIR/udp-custom.new"
if [[ -s "$UDP_DIR/config.json" ]]; then
  cp -a "$UDP_DIR/config.json" "$UDP_DIR/config.json.bak.$(date +%Y%m%d%H%M%S)"
else
  install -m 0644 "$CONFIG_SOURCE" "$UDP_DIR/config.json"
  if [[ "${UDP_CUSTOM_DEFAULT_PORT:-36712}" != 36712 ]]; then
    sed -i "s/\":36712\"/\":${UDP_CUSTOM_DEFAULT_PORT}\"/" "$UDP_DIR/config.json"
  fi
fi
mv -f "$UDP_DIR/udp-custom.new" "$UDP_DIR/udp-custom"
cat > "$SERVICE" <<'UNIT'
[Unit]
Description=UDP Custom
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=${UDP_DIR}
ExecStart=${UDP_DIR}/udp-custom server
Restart=always
RestartSec=2s
LimitNOFILE=1000000
NoNewPrivileges=true
ProtectSystem=full
ReadWritePaths=${UDP_DIR}

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now "${SERVICE_NAME}.service"
systemctl --no-pager --full status "${SERVICE_NAME}.service" || true
echo 'UDP Custom installed (default configuration listens on UDP ports 1-65535).'
