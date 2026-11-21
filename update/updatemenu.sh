#!/bin/bash
PROJECT_CONFIG_FILE="${PROJECT_CONFIG_FILE:-/etc/ssh-one/config.env}"
if [ -r "$PROJECT_CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$PROJECT_CONFIG_FILE"
fi
set -euo pipefail

PROJECT_GITHUB_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
PROJECT_GITHUB_REPO="${PROJECT_GITHUB_REPO:-SSH-xone}"
PROJECT_GITHUB_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
PROJECT_CONFIG_DIR="${PROJECT_CONFIG_DIR:-/etc/ssh-one}"
PROJECT_RAW_BASE_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}}"
PROJECT_API_BASE_URL="${PROJECT_API_BASE_URL:-https://api.github.com/repos/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"
PROJECT_VERSION_FILE="${PROJECT_VERSION_FILE:-/home/ver}"

if [ -r "$PROJECT_CONFIG_DIR/config.env" ]; then
    # shellcheck disable=SC1090
    . "$PROJECT_CONFIG_DIR/config.env"
fi
PROJECT_GITHUB_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
PROJECT_GITHUB_REPO="${PROJECT_GITHUB_REPO:-SSH-xone}"
PROJECT_GITHUB_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
PROJECT_CONFIG_DIR="${PROJECT_CONFIG_DIR:-/etc/ssh-one}"
PROJECT_RAW_BASE_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}}"
PROJECT_API_BASE_URL="${PROJECT_API_BASE_URL:-https://api.github.com/repos/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"
PROJECT_VERSION_FILE="${PROJECT_VERSION_FILE:-/home/ver}"

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "Run the updater as root." >&2
    exit 1
fi
mkdir -p "$PROJECT_CONFIG_DIR" /usr/bin
[ -f "$PROJECT_CONFIG_DIR/config.env" ] && chmod 0600 "$PROJECT_CONFIG_DIR/config.env"

download_atomic() {
    local url="$1" destination="$2" temp
    temp="${destination}.tmp.$$"
    if command -v curl >/dev/null 2>&1; then
        curl -fLsS --retry 2 --connect-timeout 15 "$url" -o "$temp"
    else
        wget -q --tries=3 -T 20 -O "$temp" "$url"
    fi
    if [ ! -s "$temp" ]; then
        rm -f "$temp"
        echo "Download failed: $url" >&2
        return 1
    fi
    tr -d '\r' < "$temp" > "${temp}.lf"
    chmod 0755 "${temp}.lf"
    mv -f "${temp}.lf" "$destination"
    rm -f "$temp"
}

# Keep local branding/repository settings; initialize them only on first update.
if [ ! -s "$PROJECT_CONFIG_DIR/config.env" ]; then
    download_atomic "${PROJECT_RAW_BASE_URL}/config.env" "$PROJECT_CONFIG_DIR/config.env"
    chmod 0600 "$PROJECT_CONFIG_DIR/config.env"
    . "$PROJECT_CONFIG_DIR/config.env"
    PROJECT_RAW_BASE_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}}"
    PROJECT_API_BASE_URL="${PROJECT_API_BASE_URL:-https://api.github.com/repos/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"
fi

declare -a downloads=(
    "SLDNS/install-sldns:install-sldns"
    "ssh/restart.sh:restart"
    "ssh/addssh.sh:addssh"
    "update/menu.sh:menu"
    "update/ipsaya.sh:ipsaya"
    "sslh-fix/sl-fix:sl-fix"
    "update/sshovpn.sh:sshovpnmenu"
    "update/l2tpmenu.sh:l2tpmenu"
    "update/pptpmenu.sh:pptpmenu"
    "update/sstpmenu.sh:sstpmenu"
    "update/wgmenu.sh:wgmenu"
    "update/ssmenu.sh:ssmenu"
    "update/ssrmenu.sh:ssrmenu"
    "update/vmessmenu.sh:vmessmenu"
    "update/vlessmenu.sh:vlessmenu"
    "update/grpcmenu.sh:grpcmenu"
    "update/grpcupdate.sh:grpcupdate"
    "grpc/xray-grpc.sh:xray-grpc"
    "update/trmenu.sh:trmenu"
    "update/trgomenu.sh:trgomenu"
    "update/setmenu.sh:setmenu"
    "update/slowdnsmenu.sh:slowdnsmenu"
    "update/running.sh:running"
    "update/updatemenu.sh:updatemenu"
    "salin/copyrepo.sh:copyrepo"
    "ssh/slhost.sh:slhost"
    "contohinfo/sl-download-info.sh:sl-download-info"
    "update/menuinfo.sh:menuinfo"
    "shadowsocks-plugin/install-ss-plugin.sh:install-ss-plugin"
    "update/udp-custom-menu.sh:udp-custom-menu"
    "hapus/uninstall:uninstall-vpn"
)

for item in "${downloads[@]}"; do
    source_path="${item%%:*}"
    command_name="${item#*:}"
    echo "Updating ${command_name}..."
    download_atomic "${PROJECT_RAW_BASE_URL}/${source_path}" "/usr/bin/${command_name}"
done

version=""
if command -v curl >/dev/null 2>&1; then
    version="$(curl -fLsS --connect-timeout 15 "${PROJECT_API_BASE_URL}/commits/${PROJECT_GITHUB_BRANCH}" 2>/dev/null | sed -n 's/.*"sha"[[:space:]]*:[[:space:]]*"\([0-9a-fA-F]\{7\}\)[0-9a-fA-F]*".*/\1/p' | head -n1 || true)"
fi
if [ -n "$version" ]; then
    printf '%s\n' "$version" > "${PROJECT_VERSION_FILE}.tmp"
    mv -f "${PROJECT_VERSION_FILE}.tmp" "$PROJECT_VERSION_FILE"
fi
echo "Menu and management scripts were updated from ${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}:${PROJECT_GITHUB_BRANCH}."
echo "Installed version: ${version:-$(cat "$PROJECT_VERSION_FILE" 2>/dev/null || echo unknown)}"
