#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root: sudo bash install.sh' >&2; exit 1; }
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/project.sh"
. /etc/os-release
case "${ID:-}:${VERSION_ID:-}" in
  debian:9|debian:10|debian:11|ubuntu:18.04|ubuntu:20.04) ;;
  *) echo "Unsupported OS: ${PRETTY_NAME:-unknown}. Supported: Debian 9/10/11, Ubuntu 18.04/20.04." >&2; exit 1 ;;
esac
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl tar wget screen bzip2 gzip coreutils unzip
mkdir -p "$(dirname "$PROJECT_ROOT")" "$PROJECT_CONFIG_DIR"
stage="$(mktemp -d)"; trap 'rm -rf -- "$stage"' EXIT
if [[ -f "$HERE/setup.sh" ]]; then src="$HERE"; else
  curl -fL --retry 3 "$PROJECT_ARCHIVE_URL" -o "$stage/project.tar.gz"
  tar -xzf "$stage/project.tar.gz" -C "$stage"
  src="$(find "$stage" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
fi
[[ -n "$src" && -f "$src/setup.sh" ]] || { echo 'Could not find project setup.sh.' >&2; exit 1; }
install -d "$PROJECT_ROOT"
cp -a "$src/." "$PROJECT_ROOT/"
install -m 0600 "$PROJECT_ROOT/config.env" "$PROJECT_CONFIG"
chmod +x "$PROJECT_ROOT/setup.sh" "$PROJECT_ROOT/update-all.sh" "$PROJECT_ROOT/uninstall.sh" "$PROJECT_ROOT/udp/"*.sh "$PROJECT_ROOT/update/menu.sh"
ln -sfn "$PROJECT_ROOT/update/menu.sh" /usr/bin/menu
ln -sfn "$PROJECT_ROOT/udp/menu.sh" /usr/bin/udp-menu
ln -sfn "$PROJECT_ROOT/update-all.sh" /usr/bin/updateall
ln -sfn "$PROJECT_ROOT/uninstall.sh" /usr/bin/uninstall-project
ln -sfn /usr/bin/updateall /usr/bin/updatemenu
if [[ -e /etc/xray/domain ]]; then
  echo 'Existing VPN install detected; scripts and commands installed, setup.sh not rerun.'
  exit 0
fi
exec "$PROJECT_ROOT/setup.sh"
