#!/bin/bash
PROJECT_CONFIG_FILE="${PROJECT_CONFIG_FILE:-/etc/ssh-one/config.env}"
if [ -r "$PROJECT_CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$PROJECT_CONFIG_FILE"
fi
PROJECT_GITHUB_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
PROJECT_GITHUB_REPO="${PROJECT_GITHUB_REPO:-SSH-xone}"
PROJECT_GITHUB_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
PROJECT_RAW_BASE_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}}"
PROJECT_RAW_HOST="${PROJECT_RAW_BASE_URL#https://}"
PROJECT_REPOSITORY_URL="${PROJECT_REPOSITORY_URL:-https://github.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}}"

cd /usr/bin

rm info-cek-tersedia
rm info-contoh-payload
rm info-contohws
rm info-exra-unli
rm info-tsel-opok
rm info-status-respon

wget -O info-cek-tersedia "${PROJECT_RAW_BASE_URL}/contohinfo/info-cek-tersedia.sh"

wget -O info-contoh-payload "${PROJECT_RAW_BASE_URL}/contohinfo/info-contoh-payload.sh"

wget -O info-contohws "${PROJECT_RAW_BASE_URL}/contohinfo/info-contohws.sh"

wget -O info-exra-unli "${PROJECT_RAW_BASE_URL}/contohinfo/info-exra-unli.sh"

wget -O info-status-respon "${PROJECT_RAW_BASE_URL}/contohinfo/info-status-respon.sh"

wget -O info-tsel-opok "${PROJECT_RAW_BASE_URL}/contohinfo/info-tsel-opok.sh"

chmod +x info-cek-tersedia
chmod +x info-contoh-payload
chmod +x info-contohws
chmod +x info-exra-unli
chmod +x info-tsel-opok
chmod +x info-status-respon

