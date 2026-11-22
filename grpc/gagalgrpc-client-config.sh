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

fileaku=grpc-client-config.json
rm /etc/xray/grpc-client-config.json
touch /etc/xray/grpc-client-config.json
cat <<EOF >>/etc/xray/grpc-client-config.json
{
    "log": {
        "loglevel": "warning" //基别
    },
    "inbounds": [{
        "listen": "127.0.0.1", //监听
        "port": "1080", //端口
        "protocol": "socks", //socks
        "settings": {
            "auth": "noauth"
        }
    }],
    "outbounds": [{
        "protocol": "vless", //vlwss协议
        "settings": {
            "vnext": [{
                "address": "$MYIP", //域名
                "port": 55443, //端口
                "users": [{
                    "id": "", //uuid
                    "encryption": "none"
                }]
            }]
        },
        "streamSettings": {
            "network": "gun", //伪装类型
            "security": "tls", //加密tls传输
            "tlsSettings": {
                "serverName": "$domain", //域名
                "alpn": [
                    "h2"
                ]
            },
            "grpcSettings": {
                "serviceName": "grpcsl" //路径类似（path）
            }
        }
    }]
}
EOF
