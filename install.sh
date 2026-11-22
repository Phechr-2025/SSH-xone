#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root: sudo bash install.sh' >&2; exit 1; }
HERE="$(cd "$(dirname "$0")" && pwd)"
if [[ -r "$HERE/lib/project.sh" ]]; then
  . "$HERE/lib/project.sh"
else
  # This file is also the one-file bootstrap downloaded by the install command.
  PROJECT_GITHUB_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
  PROJECT_GITHUB_REPO="${PROJECT_GITHUB_REPO:-SSH-xone}"
  PROJECT_GITHUB_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
  PROJECT_BRAND="${PROJECT_BRAND:-$PROJECT_GITHUB_OWNER}"
  PROJECT_SLUG="${PROJECT_SLUG:-ssh-xone}"
  PROJECT_CONFIG_DIR="${PROJECT_CONFIG_DIR:-/etc/ssh-one}"
  PROJECT_RAW_BASE_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}}"
  PROJECT_REPOSITORY_URL="${PROJECT_REPOSITORY_URL:-https://github.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"
  PROJECT_API_BASE_URL="${PROJECT_API_BASE_URL:-https://api.github.com/repos/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"
  PROJECT_VERSION_FILE="${PROJECT_VERSION_FILE:-/home/ver}"
  PROJECT_NAME="$PROJECT_GITHUB_REPO"
  PROJECT_OWNER="$PROJECT_GITHUB_OWNER"
  PROJECT_BRANCH="$PROJECT_GITHUB_BRANCH"
  PROJECT_DISPLAY_NAME="$PROJECT_BRAND"
  PROJECT_ROOT="${PROJECT_ROOT:-/opt/${PROJECT_SLUG}}"
  PROJECT_CONFIG="$PROJECT_CONFIG_DIR/config.env"
  PROJECT_ARCHIVE_URL="${PROJECT_REPOSITORY_URL}/archive/refs/heads/${PROJECT_GITHUB_BRANCH}.tar.gz"
  export PROJECT_GITHUB_OWNER PROJECT_GITHUB_REPO PROJECT_GITHUB_BRANCH PROJECT_BRAND PROJECT_SLUG
  export PROJECT_CONFIG_DIR PROJECT_RAW_BASE_URL PROJECT_REPOSITORY_URL PROJECT_API_BASE_URL PROJECT_VERSION_FILE
  export PROJECT_NAME PROJECT_OWNER PROJECT_BRANCH PROJECT_DISPLAY_NAME PROJECT_ROOT PROJECT_CONFIG PROJECT_ARCHIVE_URL
fi
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
chmod +x "$PROJECT_ROOT/setup.sh" "$PROJECT_ROOT/update-all.sh" "$PROJECT_ROOT/uninstall.sh" "$PROJECT_ROOT/udp/"*.sh "$PROJECT_ROOT/update/menu.sh" "$PROJECT_ROOT/update/udp-custom-menu.sh"
ln -sfn "$PROJECT_ROOT/update/menu.sh" /usr/bin/menu
ln -sfn "$PROJECT_ROOT/udp/menu.sh" /usr/bin/udp-menu
ln -sfn "$PROJECT_ROOT/update/udp-custom-menu.sh" /usr/bin/udp-custom-menu
ln -sfn "$PROJECT_ROOT/update-all.sh" /usr/bin/updateall
ln -sfn "$PROJECT_ROOT/uninstall.sh" /usr/bin/uninstall-project
ln -sfn /usr/bin/updateall /usr/bin/updatemenu
if [[ -e /etc/xray/domain ]]; then
  echo 'Existing VPN install detected; scripts and commands installed, setup.sh not rerun.'
  exit 0
fi
exec "$PROJECT_ROOT/setup.sh"
