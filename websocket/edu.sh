#!/bin/bash
PROJECT_CONFIG_FILE="${PROJECT_CONFIG_FILE:-/etc/ssh-one/config.env}"
if [ -r "$PROJECT_CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$PROJECT_CONFIG_FILE"
fi
PROJECT_GITHUB_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
PROJECT_GITHUB_REPO="${PROJECT_GITHUB_REPO:-SSH-xone}"
PROJECT_GITHUB_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
PROJECT_RAW_BASE_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}}"
PROJECT_RAW_HOST="${PROJECT_RAW_BASE_URL#https://}"
PROJECT_REPOSITORY_URL="${PROJECT_REPOSITORY_URL:-https://github.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"
# Proxy For Edukasi & Imclass
# ==========================================

# Link Hosting Kalian
akbarvpn="${PROJECT_RAW_HOST}/websocket"

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
Description=Python proxy service
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
