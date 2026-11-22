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
# ==========================================
# Color
# hapus menu
rm -rf menu
rm -rf ipsaya
rm -rf sl-fix
rm -rf sshovpnmenu
rm -rf l2tpmenu
rm -rf pptpmenu
rm -rf sstpmenu
rm -rf wgmenu
rm -rf ssmenu
rm -rf ssrmenu
rm -rf vmessmenu
rm -rf vlessmenu
rm -rf grpcmenu
rm -rf grpcupdate
rm -rf trmenu
rm -rf trgomenu
rm -rf setmenu
rm -rf slowdnsmenu
rm -rf running
rm -rf copyrepo

# download menu
cd /usr/bin
rm -rf menu
rm -rf menuinfo
rm -rf restart
rm -rf slhost
rm -rf install-sldns
rm -rf addssh
wget -O install-sldns "${PROJECT_RAW_URL}/SLDNS/install-sldns"
wget -O restart "${PROJECT_RAW_URL}/ssh/restart.sh"
wget -O addssh "${PROJECT_RAW_URL}/ssh/addssh.sh"
wget -O menu "${PROJECT_RAW_URL}/update/menu.sh"
wget -O ipsaya "${PROJECT_RAW_URL}/update/ipsaya.sh"
wget -O sl-fix "${PROJECT_RAW_URL}/sslh-fix/sl-fix"
wget -O sshovpnmenu "${PROJECT_RAW_URL}/update/sshovpn.sh"
wget -O l2tpmenu "${PROJECT_RAW_URL}/update/l2tpmenu.sh"
wget -O pptpmenu "${PROJECT_RAW_URL}/update/pptpmenu.sh"
wget -O sstpmenu "${PROJECT_RAW_URL}/update/sstpmenu.sh"
wget -O wgmenu "${PROJECT_RAW_URL}/update/wgmenu.sh"
wget -O ssmenu "${PROJECT_RAW_URL}/update/ssmenu.sh"
wget -O ssrmenu "${PROJECT_RAW_URL}/update/ssrmenu.sh"
wget -O vmessmenu "${PROJECT_RAW_URL}/update/vmessmenu.sh"
wget -O vlessmenu "${PROJECT_RAW_URL}/update/vlessmenu.sh"
wget -O xray-grpc "${PROJECT_RAW_URL}/grpc/xray-grpc.sh"
wget -O grpcmenu "${PROJECT_RAW_URL}/update/grpcmenu.sh"
wget -O grpcupdate "${PROJECT_RAW_URL}/update/grpcupdate.sh"
wget -O trmenu "${PROJECT_RAW_URL}/update/trmenu.sh"
wget -O trgomenu "${PROJECT_RAW_URL}/update/trgomenu.sh"
wget -O setmenu "${PROJECT_RAW_URL}/update/setmenu.sh"
wget -O slowdnsmenu "${PROJECT_RAW_URL}/update/slowdnsmenu.sh"
wget -O running "${PROJECT_RAW_URL}/update/running.sh"
wget -O updatemenu "${PROJECT_RAW_URL}/update/updatemenu.sh"
wget -O copyrepo "${PROJECT_RAW_URL}/salin/copyrepo.sh"
wget -O slhost "${PROJECT_RAW_URL}/ssh/slhost.sh"
wget -O sl-download-info "${PROJECT_RAW_URL}/contohinfo/sl-download-info.sh"
wget -O menuinfo "${PROJECT_RAW_URL}/update/menuinfo.sh"
wget -O install-ss-plugin "${PROJECT_RAW_URL}/shadowsocks-plugin/install-ss-plugin.sh"

chmod +x install-ss-plugin
chmod +x xray-grpc
chmod +x install-sldns
chmod +x restart
chmod +x addssh
chmod +x grpcmenu2
chmod +x grpc2
chmod +x grpcupdate2
chmod +x sl-download-info
chmod +x menuinfo
chmod +x slhost
chmod +x copyrepo
chmod +x menu
chmod +x ipsaya
chmod +x sl-fix
chmod +x sshovpnmenu
chmod +x l2tpmenu
chmod +x pptpmenu
chmod +x sstpmenu
chmod +x wgmenu
chmod +x ssmenu
chmod +x ssrmenu
chmod +x vmessmenu
chmod +x vlessmenu
chmod +x grpcmenu
chmod +x grpcupdate
chmod +x trmenu
chmod +x trgomenu
chmod +x setmenu
chmod +x slowdnsmenu
chmod +x running
chmod +x updatemenu
sl-download-info
#install-sldns
#install-ss-plugin
#xray-grpc
cd
