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
# Getting
clear
IP=$(wget -qO- ipinfo.io/ip);
date=$(date +"%Y-%m-%d-%H:%M:%S")
domain=$(cat /etc/xray/domain)
clear
#email=$(cat /home/email)
#if [[ "$email" = "" ]]; then
#echo "Please Enter Email for Receive Backup"
#read -rp "Email : " -e email
#cat <<EOF>>/home/email
#$email
#EOF
#fi
#clear
echo "Please Wait, Backup Process is in progress !!"
rm -rf /root/backup
mkdir /root/backup
cp /etc/passwd backup/
cp /etc/group backup/
cp /etc/shadow backup/
cp /etc/gshadow backup/
cp -r /etc/wireguard backup/wireguard
cp /etc/ppp/chap-secrets backup/chap-secrets
cp /etc/ipsec.d/passwd backup/passwd1
cp /etc/shadowsocks-libev/akun.conf backup/ss.conf
cp -r /var/lib/crot/ backup/crot
cp -r /home/sstp backup/sstp
cp -r /etc/xray backup/xray
cp -r /root/nsdomain backup/nsdomain
cp -r /etc/slowdns backup/slowdns
cp -r /etc/trojan-go backup/trojan-go
cp -r /usr/local/shadowsocksr/ backup/shadowsocksr
cp -r /home/vps/public_html backup/public_html
cd /root
zip -r $IP-$date-$domain-hop.zip backup > /dev/null 2>&1
rclone copy /root/$IP-$date-$domain-hop.zip dr:backup/
url=$(rclone link dr:backup/$IP-$date-$domain-hop.zip)
id=(`echo $url | grep '^https' | cut -d'=' -f2`)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"
echo -e "
Detail Backup 
==================================
IP VPS        : $IP
Link Backup   : $link
Date          : $date
==================================
" | mail -s "Backup Data" $email
rm -rf /root/backup
rm -r /root/$IP-$date-$domain-hop.zip
clear
echo -e "
Detail Backup 
==================================
IP VPS        : $IP
Link Backup   : $link
Date          : $date
==================================
"
echo "Please check Inbox $email"
