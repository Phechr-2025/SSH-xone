#!/bin/bash
CONFIG_FILE="${PROJECT_CONFIG_FILE:-/etc/ssh-one/config.env}"
if [ -r "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
fi
PROJECT_BRAND="${PROJECT_BRAND:-SSH-one}"
PROJECT_VERSION_FILE="${PROJECT_VERSION_FILE:-/home/ver}"

get_file() {
    [ -r "$1" ] && tr -d '\r\n' < "$1" || printf '%s' "${2:-N/A}"
}
get_count() {
    if [ -r "$1" ]; then
        grep -c -E "$2" "$1" 2>/dev/null || true
    else
        printf '0'
    fi
}
run_command() {
    local command="$1"
    if command -v "$command" >/dev/null 2>&1; then
        "$command"
    else
        echo "Command '$command' is not installed. Run updatemenu to refresh the menus."
        read -r -p "Press Enter to return..." _
    fi
}

while true; do
    clear
    cores="$(nproc 2>/dev/null || printf '1')"
    cpu_usage="$(top -bn1 2>/dev/null | awk '/Cpu\(s\)/ {printf "%.0f%%", 100-$8; found=1} END {if (!found) print "N/A"}')"
    domain="$(get_file /etc/xray/domain N/A)"
    nameserver="$(get_file /root/nsdomain N/A)"
    ip="$(curl -fsS --max-time 5 https://ipv4.icanhazip.com 2>/dev/null | tr -d '\r\n')"
    [ -n "$ip" ] || ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
    os="$(. /etc/os-release 2>/dev/null; printf '%s' "${PRETTY_NAME:-Unknown OS}")"
    uptime_text="$(uptime -p 2>/dev/null | sed 's/^up //')"
    [ -n "$uptime_text" ] || uptime_text="N/A"
    ram_total="$(free -m 2>/dev/null | awk 'NR==2 {print $2}')"
    ram_used="$(free -m 2>/dev/null | awk 'NR==2 {print $3}')"
    udp_group="${UDP_CUSTOM_GROUP:-udp-custom}"
    udp_gid="$(getent group "$udp_group" 2>/dev/null | awk -F: 'NR == 1 {print $3}')"
    ssh_count="$(awk -F: -v gid="$udp_gid" '$3 >= 1000 && $1 != "nobody" && (gid == "" || $4 != gid) {n++} END {print n+0}' /etc/passwd 2>/dev/null)"
    udp_count="0"
    [ -n "$udp_gid" ] && udp_count="$(awk -F: -v gid="$udp_gid" '$4 == gid {n++} END {print n+0}' /etc/passwd 2>/dev/null)"
    vmess="$(get_count /etc/xray/config.json '^### ' )"
    vless="$(get_count /etc/xray/config.json '^#### ' )"
    trojan="$(get_count /etc/xray/config.json '^#&# ' )"
    trojango="$(get_count /etc/trojan-go/akun.conf '^### ' )"
    version="$(get_file "$PROJECT_VERSION_FILE" unknown)"
    interface="$(ip -o -4 route show to default 2>/dev/null | awk 'NR==1 {print $5}')"
    [ -n "$interface" ] || interface="eth0"
    today="$(vnstat -i "$interface" 2>/dev/null | awk '/today/ {print $8" "$9; exit}')"
    yesterday="$(vnstat -i "$interface" 2>/dev/null | awk '/yesterday/ {print $8" "$9; exit}')"
    month="$(vnstat -i "$interface" -m 2>/dev/null | awk -v m="$(date +"%b '%y")" '$0 ~ m {print $9" "$10; exit}')"
    echo
    echo "                        MAIN MENU"
    printf '                   %s\n' "$PROJECT_BRAND"
    echo "————————————————————————————————————————————————————————"
    echo "                   ♦️ Server Information ♦️"
    echo "————————————————————————————————————————————————————————"
    printf ' ♦️ OS       : %s\n' "$os"
    printf ' ♦️ KERNEL   : %s\n' "$(uname -r)"
    printf ' ♦️ UPTIME   : %s\n' "$uptime_text"
    printf ' ♦️ CPU      : %s core (%s)\n' "$cores" "$cpu_usage"
    printf ' ♦️ RAM      : %s MB / %s MB\n' "${ram_used:-N/A}" "${ram_total:-N/A}"
    printf ' ♦️ DOMAIN   : %s\n' "$domain"
    printf ' ♦️ DNSTT    : %s\n' "$nameserver"
    printf ' ♦️ IPVPS    : %s\n' "${ip:-N/A}"
    printf ' ♦️ Version  : %s\n' "$version"
    echo "————————————————————————————————————————————————————————"
    echo "                    ♦️ Total Bandwidth ♦️"
    echo "————————————————————————————————————————————————————————"
    printf ' ♦️ Daily Usage         : %s\n' "${today:-N/A}"
    printf ' ♦️ Yesterday Usage     : %s\n' "${yesterday:-N/A}"
    printf ' ♦️ Monthly Usage       : %s\n' "${month:-N/A}"
    echo "————————————————————————————————————————————————————————"
    echo "   SSH     UDP     VMESS     VLESS     TROJAN     TROJANGO"
    printf '   %-7s %-7s %-9s %-9s %-11s %s\n' "$ssh_count" "$udp_count" "$vmess" "$vless" "$trojan" "$trojango"
    echo "————————————————————————————————————————————————————————"
    echo "1.  UDP CUSTOM MENU"
    echo "2.  SSH WEBSOCKET MENU"
    echo "3.  L2TP MENU"
    echo "4.  PPTP MENU"
    echo "5.  SSTP MENU"
    echo "6.  WIREGUARD MENU"
    echo "7.  SHADOWSOCKS MENU"
    echo "8.  SHADOWSOCKSR MENU"
    echo "9.  XRAY VMESS MENU"
    echo "10. XRAY VLESS MENU"
    echo "11. XRAY TROJAN MENU"
    echo "12. TROJAN GO MENU"
    echo "13. INFO ALL PORT"
    echo "14. XRAY VERSION"
    echo "15. CHECK IP PORT"
    echo "16. CHECK SERVICE VPN"
    echo "17. UPDATE MENU"
    echo "18. FIX SSLH + WS-TLS AFTER REBOOT"
    echo "19. SETTINGS"
    echo "20. CHECK CPU & RAM"
    echo "21. CHECK BANDWIDTH"
    echo "22. DNS CHANGER"
    echo "23. NETFLIX CHECKER"
    echo "24. DELETE EXPIRED USERS"
    echo "25. EXIT"
    echo "————————————————————————————————————————————————————————"
    read -r -p "Select From Options [ 1 - 25 ] : " choice
    case "$choice" in
        1) run_command udp-custom-menu ;;
        2) run_command sshovpnmenu ;;
        3) run_command l2tpmenu ;;
        4) run_command pptpmenu ;;
        5) run_command sstpmenu ;;
        6) run_command wgmenu ;;
        7) run_command ssmenu ;;
        8) run_command ssrmenu ;;
        9) run_command vmessmenu ;;
        10) run_command vlessmenu ;;
        11) run_command trmenu ;;
        12) run_command trgomenu ;;
        13) run_command info ;;
        14) xray version; read -r -p "Press Enter to return..." _ ;;
        15) run_command ipsaya ;;
        16) run_command running ;;
        17) run_command updatemenu; read -r -p "Press Enter to return..." _ ;;
        18) run_command sl-fix ;;
        19) run_command setmenu ;;
        20) htop || top; read -r -p "Press Enter to return..." _ ;;
        21) vnstat -i "$interface"; read -r -p "Press Enter to return..." _ ;;
        22) run_command dns ;;
        23) run_command netf ;;
        24) delexp && xp && restart ;;
        25) exit 0 ;;
        *) echo "Choose an option from 1 to 25."; sleep 1 ;;
    esac
done
