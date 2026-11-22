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
# By ${PROJECT_OWNER:-SSH-one}
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================

clear
echo -e ""
echo -e "======================================"
echo -e ""
echo -e "[1]. Change Port OpenVPN"
echo -e "[2]. Change Port Wireguard"
echo -e "[3]. Change Port Vmess + Vless"
echo -e "[4]. Change Port Trojan"
echo -e "[5]. Change Port Squid"
echo -e "[6]. Change Port SSTP"
echo -e "[7]. Change Port SSH WS HTTP"
echo -e "[8]. Change Port SSH WS TLS / SSL"
echo -e "[9]. Exit"
echo -e ""
echo -e "======================================"
echo -e ""
read -p "Select From Options [ 1-7 ] : " port
echo -e ""
case $port in
1)
portovpn
;;
2)
portwg
;;
3)
portvlm
;;
4)
porttrojan
;;
5)
portsquid
;;
6)
portsstp
;;
7)
portsshnontls
;;
8)
portsshws
;;
9)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac
