#!/bin/bash

# Load settings from the one installed config file or this source tree.
if [ -r /etc/ssh-one/config.env ]; then . /etc/ssh-one/config.env
else
  _PROJECT_SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
  for _PROJECT_ENV in "$_PROJECT_SCRIPT_DIR/config.env" "$_PROJECT_SCRIPT_DIR/../config.env"; do
    if [ -r "$_PROJECT_ENV" ]; then . "$_PROJECT_ENV"; break; fi
  done
fi
PROJECT_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
PROJECT_NAME="${PROJECT_GITHUB_REPO:-SSH-xone}"
PROJECT_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
PROJECT_DISPLAY_NAME="${PROJECT_BRAND:-$PROJECT_OWNER}"
PROJECT_DOMAIN="${PROJECT_CLOUDFLARE_DOMAIN:-}"
PROJECT_CF_EMAIL="${PROJECT_CLOUDFLARE_EMAIL:-}"
PROJECT_CF_KEY="${PROJECT_CLOUDFLARE_API_KEY:-}"
PROJECT_RAW_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_OWNER}/${PROJECT_NAME}/${PROJECT_BRANCH}}"
export PROJECT_OWNER PROJECT_NAME PROJECT_BRANCH PROJECT_DISPLAY_NAME PROJECT_DOMAIN PROJECT_CF_EMAIL PROJECT_CF_KEY PROJECT_RAW_URL
# Proxy For Edukasi & Imclass
# By ${PROJECT_OWNER:-SSH-one}
# ==========================================

# Link Hosting Kalian
akbarvpn="raw.githubusercontent.com/${PROJECT_OWNER}/${PROJECT_NAME}/${PROJECT_BRANCH}/websocket"

# Getting Proxy Template
wget -q -O /usr/local/bin/ws-nontls https://${akbarvpn}/websocket.py
chmod +x /usr/local/bin/ws-nontls

# Installing Service
cat > /etc/systemd/system/ws-nontls.service << END
[Unit]
Description=Python Proxy Mod By Akbar Maulana
Documentation=https://nekopi.care
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/ws-nontls 8880
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable ws-nontls
systemctl restart ws-nontls

# Getting Proxy Template
wget -q -O /usr/local/bin/ws-ovpn https://${akbarvpn}/ws-ovpn.py
chmod +x /usr/local/bin/ws-ovpn

# Installing Service
cat > /etc/systemd/system/ws-ovpn.service << END
[Unit]
Description=Python Proxy Mod By nevermoressh
Documentation=https://nekopoi.care
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/ws-ovpn 2086
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable ws-ovpn
systemctl restart ws-ovpn

# Getting Proxy Template
wget -q -O /usr/local/bin/ws-tls https://${akbarvpn}/ws-tls
chmod +x /usr/local/bin/ws-tls

# Installing Service
cat > /etc/systemd/system/ws-tls.service << END
[Unit]
Description=Python Proxy Mod By geovpn
Documentation=https://nekopoi.care
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/ws-tls 443
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable ws-tls
systemctl restart ws-tls
