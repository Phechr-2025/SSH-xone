#!/usr/bin/env bash
set -u
SCRIPT_PATH="$(readlink -f "$0")"
ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
. "$ROOT/lib/project.sh"
cmd() { command -v "$1" >/dev/null 2>&1; }
read_file() { [[ -r "$1" ]] && tr -d '\r\n' < "$1" || printf '%s' 'N/A'; }
os_name="$(. /etc/os-release 2>/dev/null; printf '%s %s' "${PRETTY_NAME:-Linux}" "${VERSION_ID:-}")"
domain="$(read_file /etc/xray/domain)"; [[ $domain != N/A ]] || domain="$(read_file /root/domain)"
dns="$(read_file /root/nsdomain)"
ip="$(curl -fsS --max-time 3 https://api.ipify.org 2>/dev/null || printf N/A)"
cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '?')"
uptime_text="$(uptime -p 2>/dev/null || uptime 2>/dev/null)"
cpu_load="$(awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null)"
ram="$(free -h 2>/dev/null | awk '/Mem:/ {print $3" / "$2}')"
version="$(project_version)"
count_users() { local f=$1 pattern=$2; if [[ -r "$f" ]]; then grep -cE "$pattern" "$f" 2>/dev/null || true; else printf 0; fi; }
ssh_count="$(awk -F: '$3>=1000 && $1!="nobody" {n++} END{print n+0}' /etc/passwd 2>/dev/null)"
vmess_count="$(count_users /etc/xray/config.json '^### ')"
vless_count="$(count_users /etc/xray/config.json '^#### ')"
trojan_count="$(count_users /etc/xray/config.json '^#&# ')"
trojango_count="$(count_users /etc/trojan-go/akun.conf '^### ')"
udp_count=0 # UDP Custom is a shared service, not a per-user account list.
usage="N/A"; yesterday="N/A"; monthly="N/A"
if cmd vnstat; then
  iface="$(ip -o route show default 2>/dev/null | awk 'NR==1 {print $5}')"
  if [[ -n $iface ]]; then
    usage="$(vnstat -i "$iface" 2>/dev/null | awk '/today/ {print $(NF-2),$(NF-1),$NF; exit}')"; [[ -n $usage ]] || usage=N/A
    yesterday="$(vnstat -i "$iface" 2>/dev/null | awk '/yesterday/ {print $(NF-2),$(NF-1),$NF; exit}')"; [[ -n $yesterday ]] || yesterday=N/A
    monthly="$(vnstat -i "$iface" -m 2>/dev/null | awk 'NR==6 {print $(NF-2),$(NF-1),$NF}')"; [[ -n $monthly ]] || monthly=N/A
  fi
fi
clear 2>/dev/null || true
printf '\n                         MAIN MENU\n                     %s\n' "$PROJECT_DISPLAY_NAME"
printf '%s\n' '————————————————————————————————————————————————————————' '                  ♦️ Server Information ♦️' '————————————————————————————————————————————————————————'
printf ' ♦️ OS       : %s\n ♦️ KERNEL   : %s\n ♦️ UPTIME   : %s\n ♦️ CPU      : %s core (load %s)\n ♦️ RAM      : %s\n ♦️ DOMAIN   : %s\n ♦️ DNSTT    : %s\n ♦️ IPVPS    : %s\n ♦️ Version  : %s\n' "$os_name" "$(uname -r)" "$uptime_text" "$cores" "$cpu_load" "$ram" "$domain" "$dns" "$ip" "$version"
printf '%s\n' '————————————————————————————————————————————————————————' '                    ♦️ Total Bandwidth ♦️' '————————————————————————————————————————————————————————'
printf ' ♦️ Daily Usage         : %s\n ♦️ Yesterday Usage     : %s\n ♦️ Monthly Usage       : %s\n' "$usage" "$yesterday" "$monthly"
printf '%s\n' '————————————————————————————————————————————————————————' ' UDP      SSH     VMESS     VLESS     TROJAN     TROJANGO'
printf ' %-8s %-7s %-9s %-9s %-10s %s\n' "$udp_count" "$ssh_count" "$vmess_count" "$vless_count" "$trojan_count" "$trojango_count"
printf '%s\n' '————————————————————————————————————————————————————————'
cat <<'MENU'
1.  UDP
2.  SSH WEBSOCKET MENU
3.  L2TP MENU
4.  PPTP MENU
5.  SSTP MENU
6.  WIREGUARD MENU
7.  SHADOWSOCKS MENU
8.  SHADOWSOCKSR MENU
9.  XRAY VMESS MENU
10. XRAY VLESS MENU
11. XRAY TROJAN MENU
12. TROJAN GO MENU
13. INFO ALL PORT
14. XRAY VERSION
15. CHECK IP PORT
16. CHECK SERVICE VPN
17. UPDATE SSH / MENU (Update)
18. FIX SSLH+WS-TLS Error after reboot
19. SETTINGS
20. CHECK CPU & RAM
21. CHECK BANDWIDTH
22. DNS CHANGER
23. NETFLIX CHECKER
24. DELETE EXPIRED USERS
25. EXIT
————————————————————————————————————————————————————————
MENU
read -r -p 'Select From Options [ 1 - 25 ] : ' choice
case "$choice" in
  1) exec bash "$ROOT/udp/menu.sh" ;;
  2) sshovpnmenu ;;
  3) l2tpmenu ;;
  4) pptpmenu ;;
  5) sstpmenu ;;
  6) wgmenu ;;
  7) ssmenu ;;
  8) ssrmenu ;;
  9) vmessmenu ;;
  10) vlessmenu ;;
  11) trmenu ;;
  12) trgomenu ;;
  13) info ;;
  14) xray version ;;
  15) ipsaya ;;
  16) running ;;
  17) updateall ;;
  18) sl-fix ;;
  19) setmenu ;;
  20) htop ;;
  21) vnstat ;;
  22) dns ;;
  23) netf ;;
  24) delexp && xp && restart ;;
  25) exit 0 ;;
  *) echo 'Invalid option.'; sleep 1; exec "$0" ;;
esac
