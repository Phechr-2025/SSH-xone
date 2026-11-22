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
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Project author is configured in project.env
# (C) Copyright 2022
# =========================================
clear
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
NUMBER_OF_CLIENTS=$(grep -c -E "^#### " "/etc/xray/config.json")
        if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
                echo -e "---------------------------------------------------"
                echo -e "---------=[ Check XRAYS/Vless WS Config ]=---------"
                echo -e "---------------------------------------------------"
                echo ""
                echo "You have no existing clients!"
                clear
                exit 1
        fi

        echo -e "---------------------------------------------------"
        echo -e "---------=[ Check XRAYS/Vless WS Config ]=---------"
        echo -e "---------------------------------------------------"
        echo " Select the existing client to view the config"
        echo " Press CTRL+C to return"
		echo -e "---------------------------------------------------"
        echo "     No  Expired   User"
        grep -E "^#### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
        until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
                if [[ ${CLIENT_NUMBER} == '1' ]]; then
                        read -rp "Select one client [1]: " CLIENT_NUMBER
                else
                        read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
                fi
        done
clear
user=$(grep -E "^#### " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
domain=$(cat /etc/xray/domain)
uuid=$(grep "},{" /etc/xray/config.json | cut -b 11-46 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#### " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
hariini=`date -d "0 days" +"%Y-%m-%d"`
tls="$(cat ~/log-install.txt | grep -w "Vless TLS" | cut -d: -f2|sed 's/ //g')"
nontls="$(cat ~/log-install.txt | grep -w "Vless None TLS" | cut -d: -f2|sed 's/ //g')"

xrayvless1="vless://${uuid}@${domain}:$tls?type=ws&encryption=none&security=tls&host=${domain}&path=/vless&allowInsecure=1&sni=${sni}#XRAY_VLESS_${user}"
xrayvless2="vless://${uuid}@${domain}:$nontls?type=ws&encryption=none&security=none&host=${domain}&path=/vless#XRAY_VLESS_${user}"

clear
echo -e ""
echo -e "======-XRAYS/VLESS-======"
echo -e "Remarks     : ${user}"
echo -e "IP/Host     : ${MYIP}"
echo -e "Address     : ${domain}"
echo -e "Port TLS    : $tls"
echo -e "Port No TLS : $nontls"
echo -e "User ID     : ${uuid}"
echo -e "Encryption  : none"
echo -e "Network     : ws"
echo -e "Path        : /vless"
echo -e "Multipath   : /yourpath (XrayCore Mod)"
echo -e "Created     : $hariini"
echo -e "Expired     : $exp"
echo -e "========================="
echo -e "Link TLS    : ${xrayvless1}"
echo -e "========================="
echo -e "Link No TLS : ${xrayvless2}"
echo -e "========================="
echo -e "Script Mod By ${PROJECT_OWNER:-SSH-one}"
