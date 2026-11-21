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
# ==========================================
# ==========================================
# 
cd

cd /usr/bin


wget -O fb-addgrpc "${PROJECT_RAW_BASE_URL}/grpc/fb-addgrpc.sh"
wget -O fb-delgrpc "${PROJECT_RAW_BASE_URL}/grpc/fb-delgrpc.sh"
wget -O fb-renewgrpc "${PROJECT_RAW_BASE_URL}/grpc/fb-renewgrpc.sh"
wget -O fb-cekgrpc "${PROJECT_RAW_BASE_URL}/grpc/fb-cekgrpc.sh"

chmod +x fb-addgrpc
chmod +x fb-delgrpc
chmod +x fb-renewgrpc
chmod +x fb-cekgrpc

cd
