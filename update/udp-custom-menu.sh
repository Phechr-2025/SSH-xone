#!/bin/bash
set -o nounset

CONFIG_FILE="${PROJECT_CONFIG_FILE:-/etc/ssh-one/config.env}"
if [ -r "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
fi
PROJECT_BRAND="${PROJECT_BRAND:-SSH-one}"
UDP_CUSTOM_BINARY_URL="${UDP_CUSTOM_BINARY_URL:-}"
UDP_CUSTOM_CONFIG_URL="${UDP_CUSTOM_CONFIG_URL:-}"
UDP_CUSTOM_ROOT="${UDP_CUSTOM_ROOT:-/root/udp}"
UDP_CUSTOM_SERVICE="${UDP_CUSTOM_SERVICE:-udp-custom}"
UDP_CUSTOM_DEFAULT_PORT="${UDP_CUSTOM_DEFAULT_PORT:-36712}"
UDP_CUSTOM_GROUP="${UDP_CUSTOM_GROUP:-udp-custom}"

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

fetch_file() {
    local url="$1" destination="$2" temporary
    temporary="${destination}.tmp.$$"
    if command -v curl >/dev/null 2>&1; then
        curl -fLsS --retry 2 --connect-timeout 15 "$url" -o "$temporary"
    elif command -v wget >/dev/null 2>&1; then
        wget -q --tries=3 -T 20 -O "$temporary" "$url"
    else
        echo "Install curl or wget first." >&2
        return 1
    fi
    if [ ! -s "$temporary" ]; then
        rm -f "$temporary"
        echo "Download failed or returned an empty file: $url" >&2
        return 1
    fi
    install -m 0644 "$temporary" "$destination" || { rm -f "$temporary"; return 1; }
    rm -f "$temporary"
}

udp_port() {
    local port
    port="$(sed -n 's/.*"listen"[[:space:]]*:[[:space:]]*"[^:]*:\([0-9][0-9]*\)".*/\1/p' "$UDP_CUSTOM_ROOT/config.json" | head -n1)"
    printf '%s\n' "${port:-$UDP_CUSTOM_DEFAULT_PORT}"
}

valid_excludes() {
    local value="$1" part
    [ -z "$value" ] && return 0
    [[ "$value" =~ ^[0-9,]+$ ]] || return 1
    IFS=',' read -r -a parts <<< "$value"
    for part in "${parts[@]}"; do
        [ "$part" -ge 1 ] && [ "$part" -le 65535 ] || return 1
    done
}

install_udp_custom() {
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo -e "${red}Run this menu as root.${nc}"
        return 1
    fi
    if [ "$(uname -m)" != x86_64 ]; then
        echo -e "${red}The configured VVV binary is built for x86_64 Linux.${nc}"
        return 1
    fi
    if [ -z "$UDP_CUSTOM_BINARY_URL" ] || [ -z "$UDP_CUSTOM_CONFIG_URL" ]; then
        echo -e "${red}UDP Custom download URLs are missing from $CONFIG_FILE.${nc}"
        return 1
    fi

    local tmpdir exclude port
    tmpdir="$(mktemp -d)" || return 1
    if ! fetch_file "$UDP_CUSTOM_BINARY_URL" "$tmpdir/udp-custom" || ! fetch_file "$UDP_CUSTOM_CONFIG_URL" "$tmpdir/config.json"; then
        rm -rf "$tmpdir"
        echo -e "${red}Could not download UDP Custom. Existing installation was kept.${nc}"
        return 1
    fi
    if ! grep -q '"listen"' "$tmpdir/config.json"; then
        rm -rf "$tmpdir"
        echo -e "${red}The downloaded config does not look like a UDP Custom config.${nc}"
        return 1
    fi
    install -d -m 0755 "$UDP_CUSTOM_ROOT"
    install -m 0755 "$tmpdir/udp-custom" "$UDP_CUSTOM_ROOT/udp-custom" || { rm -rf "$tmpdir"; return 1; }
    if [ ! -s "$UDP_CUSTOM_ROOT/config.json" ]; then
        install -m 0644 "$tmpdir/config.json" "$UDP_CUSTOM_ROOT/config.json" || { rm -rf "$tmpdir"; return 1; }
    fi
    rm -rf "$tmpdir"

    if [ ! -s "$UDP_CUSTOM_ROOT/config.json" ]; then
        echo -e "${red}UDP Custom configuration is missing.${nc}"
        return 1
    fi
    port="$(udp_port)"
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${red}Invalid UDP listen port in $UDP_CUSTOM_ROOT/config.json.${nc}"
        return 1
    fi
    echo
    echo "UDP Custom accepts destination UDP ports from 1 to 65535."
    echo "The service's own listen port is $port."
    read -r -p "Exclude UDP ports already used by other services (comma-separated, optional): " exclude
    if ! valid_excludes "$exclude"; then
        echo -e "${red}Enter comma-separated ports from 1 to 65535.${nc}"
        return 1
    fi

    cat > "/etc/systemd/system/${UDP_CUSTOM_SERVICE}.service" <<EOF
[Unit]
Description=UDP Custom service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$UDP_CUSTOM_ROOT
ExecStart=$UDP_CUSTOM_ROOT/udp-custom server${exclude:+ -exclude $exclude}
Restart=always
RestartSec=2s
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload || return 1
    systemctl enable --now "$UDP_CUSTOM_SERVICE" || return 1
    echo -e "${green}UDP Custom is installed and enabled.${nc}"
    echo "Destination UDP port range: 1-65535"
    echo "UDP Custom listen port: $port"
}

show_info() {
    local domain ip port
    domain="$(cat /etc/xray/domain 2>/dev/null || hostname -f 2>/dev/null || hostname)"
    ip="$(curl -fsS --max-time 5 https://ipv4.icanhazip.com 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')"
    port="$(udp_port)"
    echo "UDP Custom connection information"
    echo "Host                  : $domain"
    echo "Server IP             : ${ip:-unavailable}"
    echo "UDP Custom listen port: $port"
    echo "Destination UDP ports : 1-65535"
    echo "Managed UDP accounts  : $(udp_account_count)"
    echo
    echo "Each account uses a local Linux username and password with an expiry date."
}

udp_group_gid() {
    getent group "$UDP_CUSTOM_GROUP" | awk -F: 'NR == 1 {print $3}'
}

udp_account_count() {
    local gid
    gid="$(udp_group_gid)"
    if [ -z "$gid" ]; then
        printf '0'
    else
        getent passwd | awk -F: -v gid="$gid" '$4 == gid {n++} END {print n+0}'
    fi
}

ensure_udp_group() {
    getent group "$UDP_CUSTOM_GROUP" >/dev/null 2>&1 || groupadd --system "$UDP_CUSTOM_GROUP"
}

is_udp_account() {
    local username="$1" gid user_gid
    gid="$(udp_group_gid)"
    [ -n "$gid" ] || return 1
    user_gid="$(getent passwd "$username" | awk -F: 'NR == 1 {print $4}')"
    [ -n "$user_gid" ] && [ "$user_gid" = "$gid" ]
}

valid_username() {
    [[ "$1" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]
}

read_expiry_date() {
    local entered normalized today
    read -r -p "Expiry date (YYYY-MM-DD): " entered
    normalized="$(date -d "$entered" +%F 2>/dev/null)" || return 1
    [ "$normalized" = "$entered" ] || return 1
    today="$(date +%F)"
    [[ "$normalized" > "$today" ]] || return 1
    printf '%s' "$normalized"
}

create_udp_account() {
    local username expiry password password_confirm
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "Run this menu as root." >&2
        return 1
    fi
    read -r -p "UDP username: " username
    if ! valid_username "$username"; then
        echo "Use 1-32 lowercase letters, digits, underscore, or hyphen; the first character must be a letter or underscore."
        return 1
    fi
    if getent passwd "$username" >/dev/null 2>&1; then
        echo "That username already exists on this server."
        return 1
    fi
    expiry="$(read_expiry_date)" || { echo "Enter a valid future date in YYYY-MM-DD format."; return 1; }
    read -r -s -p "Password (at least 6 characters): " password
    echo
    read -r -s -p "Confirm password: " password_confirm
    echo
    if [ "${#password}" -lt 6 ] || [[ "$password" == *:* ]] || [ "$password" != "$password_confirm" ]; then
        unset password password_confirm
        echo "Passwords must match, be at least 6 characters, and contain no colon."
        return 1
    fi
    ensure_udp_group || { unset password password_confirm; echo "Could not create the UDP account group."; return 1; }
    if ! useradd -M -g "$UDP_CUSTOM_GROUP" -s /bin/false -e "$expiry" "$username"; then
        unset password password_confirm
        echo "Could not create the UDP account."
        return 1
    fi
    if ! printf '%s:%s\n' "$username" "$password" | chpasswd; then
        userdel "$username" >/dev/null 2>&1 || true
        unset password password_confirm
        echo "Could not set the account password; the new account was removed."
        return 1
    fi
    unset password password_confirm
    echo "UDP account created: $username (expires $expiry)"
}

list_udp_accounts() {
    local gid username rest expiry
    gid="$(udp_group_gid)"
    if [ -z "$gid" ]; then
        echo "No UDP accounts found."
        return 0
    fi
    printf '%-24s %s\n' "USERNAME" "EXPIRES"
    printf '%-24s %s\n' "--------" "-------"
    while IFS=: read -r username _ _ _ _ _ _; do
        expiry="$(chage -l "$username" 2>/dev/null | sed -n 's/^Account expires[[:space:]]*:[[:space:]]*//p' | head -n1)"
        printf '%-24s %s\n' "$username" "${expiry:-unknown}"
    done < <(getent passwd | awk -F: -v gid="$gid" '$4 == gid {print $0}')
}

renew_udp_account() {
    local username expiry
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "Run this menu as root." >&2
        return 1
    fi
    read -r -p "UDP username to renew: " username
    if ! valid_username "$username" || ! is_udp_account "$username"; then
        echo "That UDP account was not found."
        return 1
    fi
    expiry="$(read_expiry_date)" || { echo "Enter a valid future date in YYYY-MM-DD format."; return 1; }
    chage -E "$expiry" "$username" && echo "UDP account $username now expires $expiry."
}

delete_udp_account() {
    local username answer
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "Run this menu as root." >&2
        return 1
    fi
    read -r -p "UDP username to delete: " username
    if ! valid_username "$username" || ! is_udp_account "$username"; then
        echo "That UDP account was not found."
        return 1
    fi
    read -r -p "Delete UDP account '$username'? [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]] || return 0
    userdel "$username" && echo "UDP account $username was deleted."
}

delete_all_udp_accounts() {
    local gid username
    gid="$(udp_group_gid)"
    if [ -n "$gid" ]; then
        while IFS=: read -r username _ _ _ _ _ _; do
            userdel "$username" >/dev/null 2>&1 || true
        done < <(getent passwd | awk -F: -v gid="$gid" '$4 == gid {print $0}')
        groupdel "$UDP_CUSTOM_GROUP" >/dev/null 2>&1 || true
    fi
}

show_status() {
    systemctl --no-pager --full status "$UDP_CUSTOM_SERVICE" 2>&1 || true
    echo
    echo "UDP Custom listen port: $(udp_port)"
}

remove_udp_custom() {
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo -e "${red}Run this menu as root.${nc}"
        return 1
    fi
    read -r -p "Remove UDP Custom service and its files? [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]] || return 0
    read -r -p "Also delete all UDP Custom accounts? [y/N]: " delete_accounts
    if [ -s "$UDP_CUSTOM_ROOT/config.json" ]; then
        cp -f "$UDP_CUSTOM_ROOT/config.json" "/root/udp-custom-config-$(date +%Y%m%d-%H%M%S).json"
    fi
    systemctl disable --now "$UDP_CUSTOM_SERVICE" 2>/dev/null || true
    rm -f "/etc/systemd/system/${UDP_CUSTOM_SERVICE}.service"
    systemctl daemon-reload
    rm -rf "$UDP_CUSTOM_ROOT"
    [[ "$delete_accounts" =~ ^[Yy]$ ]] && delete_all_udp_accounts
    echo -e "${green}UDP Custom service and files were removed.${nc}"
}

if [ "${1:-}" = install ]; then
    install_udp_custom
    exit $?
fi

while true; do
    clear
    echo "UDP CUSTOM MENU - $PROJECT_BRAND"
    echo "────────────────────────────────────────"
    echo "Destination UDP ports: 1-65535"
    echo "Service listen port  : $(udp_port)"
    echo "────────────────────────────────────────"
    echo "1. Install / Update UDP Custom"
    echo "2. Create UDP account"
    echo "3. List UDP accounts"
    echo "4. Renew UDP account"
    echo "5. Delete UDP account"
    echo "6. Show connection information"
    echo "7. Check service status"
    echo "8. Start service"
    echo "9. Restart service"
    echo "10. Stop service"
    echo "11. Uninstall UDP Custom"
    echo "0. Back to main menu"
    read -r -p "Select [0-11]: " choice
    case "$choice" in
        1) install_udp_custom; read -r -p "Press Enter to continue..." _ ;;
        2) create_udp_account; read -r -p "Press Enter to continue..." _ ;;
        3) list_udp_accounts; read -r -p "Press Enter to continue..." _ ;;
        4) renew_udp_account; read -r -p "Press Enter to continue..." _ ;;
        5) delete_udp_account; read -r -p "Press Enter to continue..." _ ;;
        6) show_info; read -r -p "Press Enter to continue..." _ ;;
        7) show_status; read -r -p "Press Enter to continue..." _ ;;
        8) systemctl start "$UDP_CUSTOM_SERVICE"; read -r -p "Press Enter to continue..." _ ;;
        9) systemctl restart "$UDP_CUSTOM_SERVICE"; read -r -p "Press Enter to continue..." _ ;;
        10) systemctl stop "$UDP_CUSTOM_SERVICE"; read -r -p "Press Enter to continue..." _ ;;
        11) remove_udp_custom; read -r -p "Press Enter to continue..." _ ;;
        0) exit 0 ;;
        *) echo -e "${yellow}Choose one of the listed options.${nc}"; sleep 1 ;;
    esac
done
