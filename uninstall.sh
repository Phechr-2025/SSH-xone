#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root.' >&2; exit 1; }
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
. "$HERE/lib/project.sh"
PURGE_DATA=0
[[ "${1:-}" == --purge-data ]] && PURGE_DATA=1
cat <<EOF
This removes the installed ${PROJECT_DISPLAY_NAME} menu scripts and its known VPN service units.
It does not delete Linux user accounts or uninstall shared Debian packages.
Server configuration is backed up first. Use --purge-data to also delete kept configuration directories.
EOF
read -r -p 'Continue? Type REMOVE to confirm: ' confirm
[[ "$confirm" == REMOVE ]] || { echo 'Cancelled.'; exit 0; }
stamp="$(date +%Y%m%d-%H%M%S)"
backup="/root/${PROJECT_NAME}-backup-${stamp}.tar.gz"
paths=()
for p in /etc/xray /etc/trojan-go /etc/openvpn /etc/wireguard /etc/ppp /etc/stunnel5 /etc/default/sslh /etc/systemd/system/ws-tls.service /etc/systemd/system/ws-nontls.service /etc/systemd/system/ws-ovpn.service /etc/systemd/system/udp-custom.service /root/udp /root/nsdomain /root/domain /home/ver; do [[ -e "$p" ]] && paths+=("${p#/}"); done
if ((${#paths[@]})); then tar -czf "$backup" -C / "${paths[@]}"; else touch "$backup"; fi
services=(udp-custom ws-tls ws-nontls ws-ovpn sslh stunnel5 trojan-go xray ssrmu badvpn1 badvpn2 badvpn3 wg-quick@wg0 xl2tpd pptpd accel-ppp)
for service in "${services[@]}"; do systemctl disable --now "$service" 2>/dev/null || true; done
for service in "${services[@]}"; do rm -f "/etc/systemd/system/${service}.service"; done
systemctl daemon-reload
for command in menu udp-menu udp-custom-menu updatemenu updateall uninstall-project; do
  path="/usr/bin/$command"
  if [[ -L "$path" ]] && [[ "$(readlink -f "$path")" == "$PROJECT_ROOT"/* ]]; then rm -f "$path"; fi
done
[[ ! -d "$PROJECT_ROOT" ]] || rm -rf -- "$PROJECT_ROOT"
if ((PURGE_DATA)); then
  echo 'Removing kept VPN configuration after backup.'
  rm -rf -- /etc/xray /etc/trojan-go /etc/openvpn /etc/wireguard /etc/ppp /etc/stunnel5 /root/udp
fi
echo "Menu scripts removed. Backup saved at $backup. VPN accounts and shared packages remain installed."
