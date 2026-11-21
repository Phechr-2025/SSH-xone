#!/bin/bash
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

LOCAL_CONFIG_FILE="$(dirname "$(readlink -f "$0" 2>/dev/null || printf '%s' "$0")")/config.env"
PROJECT_CONFIG_DIR="${PROJECT_CONFIG_DIR:-/etc/ssh-one}"
PROJECT_CONFIG_FILE="$PROJECT_CONFIG_DIR/config.env"
if [ -s "$PROJECT_CONFIG_FILE" ]; then
	# shellcheck disable=SC1090
	. "$PROJECT_CONFIG_FILE"
elif [ -s "$LOCAL_CONFIG_FILE" ]; then
	# shellcheck disable=SC1090
	. "$LOCAL_CONFIG_FILE"
fi
PROJECT_GITHUB_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
PROJECT_GITHUB_REPO="${PROJECT_GITHUB_REPO:-SSH-xone}"
PROJECT_GITHUB_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
PROJECT_CONFIG_DIR="${PROJECT_CONFIG_DIR:-/etc/ssh-one}"
PROJECT_RAW_BASE_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}}"
PROJECT_API_BASE_URL="${PROJECT_API_BASE_URL:-https://api.github.com/repos/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"
mkdir -p "$PROJECT_CONFIG_DIR"
if [ ! -s "$PROJECT_CONFIG_FILE" ] && [ -s "$LOCAL_CONFIG_FILE" ]; then
	install -m 0600 "$LOCAL_CONFIG_FILE" "$PROJECT_CONFIG_FILE"
fi
if [ ! -s "$PROJECT_CONFIG_FILE" ]; then
	if command -v curl >/dev/null 2>&1; then
		curl -fLsS --retry 2 "$PROJECT_RAW_BASE_URL/config.env" -o "${PROJECT_CONFIG_FILE}.tmp" || exit 1
	else
		wget -q -T 20 -O "${PROJECT_CONFIG_FILE}.tmp" "$PROJECT_RAW_BASE_URL/config.env" || exit 1
	fi
	install -m 0600 "${PROJECT_CONFIG_FILE}.tmp" "$PROJECT_CONFIG_FILE"
	rm -f "${PROJECT_CONFIG_FILE}.tmp"
fi
# shellcheck disable=SC1090
. "$PROJECT_CONFIG_FILE"
chmod 0600 "$PROJECT_CONFIG_FILE"
PROJECT_GITHUB_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
PROJECT_GITHUB_REPO="${PROJECT_GITHUB_REPO:-SSH-xone}"
PROJECT_GITHUB_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
PROJECT_RAW_BASE_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}}"
PROJECT_API_BASE_URL="${PROJECT_API_BASE_URL:-https://api.github.com/repos/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"
PROJECT_RAW_HOST="${PROJECT_RAW_BASE_URL#https://}"

if [ -r /etc/os-release ]; then
	. /etc/os-release
	case "${ID:-}:${VERSION_ID:-}" in
		debian:9|debian:10|debian:11|ubuntu:18.04|ubuntu:20.04) ;;
		*) echo "Supported systems: Debian 9/10/11 and Ubuntu 18.04/20.04. Found ${PRETTY_NAME:-unknown}."; exit 1 ;;
	esac
else
	echo "Cannot identify this Linux distribution."
	exit 1
fi
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
# Component paths derive from the shared repository settings.
akbarvpn="${PROJECT_RAW_HOST}/ssh"
akbarvpnn="${PROJECT_RAW_HOST}/sstp"
akbarvpnnn="${PROJECT_RAW_HOST}/ssr"
akbarvpnnnn="${PROJECT_RAW_HOST}/shadowsocks"
akbarvpnnnnn="${PROJECT_RAW_HOST}/wireguard"
akbarvpnnnnnn="${PROJECT_RAW_HOST}/xray"
akbarvpnnnnnnn="${PROJECT_RAW_HOST}/ipsec"
akbarvpnnnnnnnn="${PROJECT_RAW_HOST}/backup"
akbarvpnnnnnnnnn="${PROJECT_RAW_HOST}/websocket"
akbarvpnnnnnnnnnn="${PROJECT_RAW_HOST}/ohp"

# Getting
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
echo "Checking VPS"
IZIN=$(wget -qO- ipinfo.io/ip);

# fix dns missing
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
echo "nameserver 2001:4860:4860::8888" >> /etc/resolv.conf
echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf


rm -f setup.sh
clear
if [ -f "/etc/xray/domain" ]; then
echo "Script Already Installed"
exit 0
fi
mkdir /var/lib/crot;
echo "IP=" >> /var/lib/crot/ipvps.conf
wget https://${akbarvpn}/slhost.sh && chmod +x slhost.sh && ./slhost.sh
#install xray
wget https://${akbarvpnnnnnn}/ins-xray.sh && chmod +x ins-xray.sh && screen -S xray ./ins-xray.sh
#install ssh ovpn
wget https://${akbarvpn}/ssh-vpn.sh && chmod +x ssh-vpn.sh && screen -S ssh-vpn ./ssh-vpn.sh
wget https://${akbarvpnn}/sstp.sh && chmod +x sstp.sh && screen -S sstp ./sstp.sh
#install ssr
wget https://${akbarvpnnn}/ssr.sh && chmod +x ssr.sh && screen -S ssr ./ssr.sh
wget https://${akbarvpnnnn}/sodosok.sh && chmod +x sodosok.sh && screen -S ss ./sodosok.sh
#installwg
wget https://${akbarvpnnnnn}/wg.sh && chmod +x wg.sh && screen -S wg ./wg.sh
#install L2TP
wget https://${akbarvpnnnnnnn}/ipsec.sh && chmod +x ipsec.sh && screen -S ipsec ./ipsec.sh
wget https://${akbarvpnnnnnnnn}/set-br.sh && chmod +x set-br.sh && ./set-br.sh
# Websocket
wget https://${akbarvpnnnnnnnnn}/edu.sh && chmod +x edu.sh && ./edu.sh
# Ohp Server
wget https://${akbarvpnnnnnnnnnn}/ohp.sh && chmod +x ohp.sh && ./ohp.sh
# Install SlowDNS
wget "${PROJECT_RAW_BASE_URL}/SLDNS/install-sldns" -O install-sldns && chmod +x install-sldns && ./install-sldns
# Informasi IP Saya dan Semua Port TCP UDP
# wget "${PROJECT_RAW_BASE_URL}/ipsaya.sh" && chmod +x ipsaya.sh
#
# install xray sl-grpc
# wget "${PROJECT_RAW_BASE_URL}/grpc/sl-grpc.sh" && chmod +x sl-grpc.sh && screen -S sl-grpc ./sl-grpc.sh
# install xray grpc
# wget "${PROJECT_RAW_BASE_URL}/grpc/xray-grpc.sh" && chmod +x xray-grpc.sh && screen -S xray-grpc ./xray-grpc.sh
# install shadowsocks plugin
# wget "${PROJECT_RAW_BASE_URL}/shadowsocks-plugin/install-ss-plugin.sh" && chmod +x install-ss-plugin.sh && ./install-ss-plugin.sh
 

rm -f /root/ssh-vpn.sh
rm -f /root/sstp.sh
rm -f /root/wg.sh
rm -f /root/ss.sh
rm -f /root/ssr.sh
rm -f /root/ins-xray.sh
rm -f /root/ipsec.sh
rm -f /root/set-br.sh
rm -f /root/edu.sh
rm -f /root/ohp.sh
rm -f /root/install
rm -f /root/sl-grpc.sh
rm -f /root/install-sldns
rm -f /root/install-ss-plugin.sh
cat <<EOF> /etc/systemd/system/autosett.service
[Unit]
Description=autosetting
Documentation=nekopoi.care

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/set.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable autosett
wget -O /etc/set.sh "https://${akbarvpn}/set.sh"
chmod +x /etc/set.sh
history -c
version=""
if command -v curl >/dev/null 2>&1; then
	version="$(curl -fLsS --connect-timeout 15 "${PROJECT_API_BASE_URL}/commits/${PROJECT_GITHUB_BRANCH}" 2>/dev/null | sed -n 's/.*"sha"[[:space:]]*:[[:space:]]*"\([0-9a-fA-F]\{7\}\)[0-9a-fA-F]*".*/\1/p' | head -n1 || true)"
fi
[ -n "$version" ] || version="unknown"
printf '%s\n' "$version" > "$PROJECT_VERSION_FILE"
printf '%s\n' "$version" > "$PROJECT_CONFIG_DIR/version"
echo " "
echo "Installation has been completed!!"echo " "
echo "============================================================================" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "----------------------------------------------------------------------------" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - SlowDNS SSH             : ALL Port SSH"  | tee -a log-install.txt
echo "   - OpenSSH                 : 22, 2253"  | tee -a log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200, SSL 990"  | tee -a log-install.txt
echo "   - Stunnel5                : 443, 445"  | tee -a log-install.txt
echo "   - Dropbear                : 443, 109, 143"  | tee -a log-install.txt
echo "   - CloudFront Websocket    : "  | tee -a log-install.txt
echo "   - SSH Websocket TLS       : 443"  | tee -a log-install.txt
echo "   - SSH Websocket HTTP      : 8880"  | tee -a log-install.txt
echo "   - Websocket OpenVPN       : 2086"  | tee -a log-install.txt
echo "   - Squid Proxy             : 3128, 8000"  | tee -a log-install.txt
echo "   - Badvpn                  : 7100, 7200, 7300"  | tee -a log-install.txt
echo "   - Nginx                   : 89"  | tee -a log-install.txt
echo "   - Wireguard               : 7070"  | tee -a log-install.txt
echo "   - L2TP/IPSEC VPN          : 1701"  | tee -a log-install.txt
echo "   - PPTP VPN                : 1732"  | tee -a log-install.txt
echo "   - SSTP VPN                : 444"  | tee -a log-install.txt
echo "   - Shadowsocks-R           : 1443-1543"  | tee -a log-install.txt
echo "   - SS-OBFS TLS             : 2443-2543"  | tee -a log-install.txt
echo "   - SS-OBFS HTTP            : 3443-3543"  | tee -a log-install.txt
echo "   - XRAYS Vmess TLS         : 8443"  | tee -a log-install.txt
echo "   - XRAYS Vmess None TLS    : 80"  | tee -a log-install.txt
echo "   - XRAYS Vless TLS         : 8443"  | tee -a log-install.txt
echo "   - XRAYS Vless None TLS    : 80"  | tee -a log-install.txt
echo "   - XRAYS Trojan            : 2083"  | tee -a log-install.txt
echo "   - XRAYS VMESS GRPC        : 1180"  | tee -a log-install.txt
echo "   - XRAYS VLESS GRPC        : 2280"  | tee -a log-install.txt
echo "   - OHP SSH                 : 8181"  | tee -a log-install.txt
echo "   - OHP Dropbear            : 8282"  | tee -a log-install.txt
echo "   - OHP OpenVPN             : 8383"  | tee -a log-install.txt
echo "   - TrojanGo                : 2087"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                : Asia/Kuala_Lumpur (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo "   - IPtables                : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo "   - IPv6                    : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On 05.00 GMT +8" | tee -a log-install.txt
echo "   - Autobackup Data" | tee -a log-install.txt
echo "   - Restore Data" | tee -a log-install.txt
echo "   - Auto Delete Expired Account" | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo "   - White Label" | tee -a log-install.txt
echo "   - Installation Log --> /root/log-install.txt"  | tee -a log-install.txt
echo ""
echo ""
echo " Reboot 15 Sec"
sleep 15
rm -f setup.sh
reboot
