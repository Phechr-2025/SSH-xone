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
# Mod By ${PROJECT_OWNER:-SSH-one}
# =====================================================

source /var/lib/crot/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi
MYIP=$(wget -qO- ipinfo.io/ip);
clear
domain=$(cat /etc/xray/domain)

fileaku=grpc-server-config.json

rm /etc/xray/grpc-server-config.json
touch /etc/xray/grpc-server-config.json
cat <<EOF >>/etc/xray/grpc-server-config.json
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [{
        "port": 16889,
        "listen": "127.0.0.1",
        "protocol": "vless",
        "settings": {
            "clients": [{
                "id": "2332424556457234556" // 填写你的 UUID
            }],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "grpc",
            "grpcSettings": {
                "serviceName": "" // 填写你的 ServiceName
            }
        }
    }],
    "outbounds": [{
            "tag": "direct",
            "protocol": "freedom",
            "settings": {}
        },
        {
            "tag": "blocked",
            "protocol": "blackhole",
            "settings": {}
        }
    ],
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [{
            "type": "field",
            "ip": [
                "geoip:private"
            ],
            "outboundTag": "blocked"
        }]
    }
}
EOF

# installl xray vless grpc tls
cat > /etc/systemd/system/xray@grpc-tls.service << END
[Unit]
Description=Xray Vless GRPC Service
Documentation=https://nekopoi.care
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/grpc-server-config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
END
#done
# restart
systemctl daemon-reload
service nginx restart
systemctl stop xray@grpc-tls.service
systemctl enable xray@grpc-tls.service
systemctl restart xray@grpc-tls.service
#done
