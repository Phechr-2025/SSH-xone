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

cd /usr/bin

rm info-cek-tersedia
rm info-contoh-payload
rm info-contohws
rm info-exra-unli
rm info-tsel-opok
rm info-status-respon

wget -O info-cek-tersedia "${PROJECT_RAW_URL}/contohinfo/info-cek-tersedia.sh"

wget -O info-contoh-payload "${PROJECT_RAW_URL}/contohinfo/info-contoh-payload.sh"

wget -O info-contohws "${PROJECT_RAW_URL}/contohinfo/info-contohws.sh"

wget -O info-exra-unli "${PROJECT_RAW_URL}/contohinfo/info-exra-unli.sh"

wget -O info-status-respon "${PROJECT_RAW_URL}/contohinfo/info-status-respon.sh"

wget -O info-tsel-opok "${PROJECT_RAW_URL}/contohinfo/info-tsel-opok.sh"

chmod +x info-cek-tersedia
chmod +x info-contoh-payload
chmod +x info-contohws
chmod +x info-exra-unli
chmod +x info-tsel-opok
chmod +x info-status-respon

