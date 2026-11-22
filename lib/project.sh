#!/usr/bin/env bash
# Load the one project settings file used by the installer and legacy scripts.
PROJECT_CONFIG="${PROJECT_CONFIG:-${PROJECT_CONFIG_DIR:-/etc/ssh-one}/config.env}"
if [[ -r "$PROJECT_CONFIG" ]]; then
  # shellcheck disable=SC1090
  . "$PROJECT_CONFIG"
elif [[ -r "$(dirname "${BASH_SOURCE[0]}")/../config.env" ]]; then
  # shellcheck disable=SC1091
  . "$(dirname "${BASH_SOURCE[0]}")/../config.env"
fi
PROJECT_OWNER="${PROJECT_GITHUB_OWNER:-Phechr-2025}"
PROJECT_NAME="${PROJECT_GITHUB_REPO:-SSH-xone}"
PROJECT_BRANCH="${PROJECT_GITHUB_BRANCH:-main}"
PROJECT_DISPLAY_NAME="${PROJECT_BRAND:-$PROJECT_OWNER}"
PROJECT_ROOT="${PROJECT_ROOT:-/opt/${PROJECT_SLUG:-ssh-one}}"
PROJECT_CONFIG_DIR="${PROJECT_CONFIG_DIR:-/etc/ssh-one}"
PROJECT_CONFIG="${PROJECT_CONFIG_DIR}/config.env"
PROJECT_RAW_URL="${PROJECT_RAW_BASE_URL:-https://raw.githubusercontent.com/${PROJECT_OWNER}/${PROJECT_NAME}/${PROJECT_BRANCH}}"
PROJECT_ARCHIVE_URL="${PROJECT_REPOSITORY_URL:-https://github.com/${PROJECT_OWNER}/${PROJECT_NAME}}/archive/refs/heads/${PROJECT_BRANCH}.tar.gz"
PROJECT_API_BASE_URL="${PROJECT_API_BASE_URL:-https://api.github.com/repos/${PROJECT_OWNER}/${PROJECT_NAME}}"
PROJECT_VERSION_FILE="${PROJECT_VERSION_FILE:-/home/ver}"
PROJECT_DOMAIN="${PROJECT_CLOUDFLARE_DOMAIN:-}"
PROJECT_CF_EMAIL="${PROJECT_CLOUDFLARE_EMAIL:-}"
PROJECT_CF_KEY="${PROJECT_CLOUDFLARE_API_KEY:-}"
export PROJECT_CONFIG PROJECT_OWNER PROJECT_NAME PROJECT_BRANCH PROJECT_DISPLAY_NAME PROJECT_ROOT PROJECT_CONFIG_DIR
export PROJECT_RAW_URL PROJECT_ARCHIVE_URL PROJECT_API_BASE_URL PROJECT_VERSION_FILE PROJECT_DOMAIN PROJECT_CF_EMAIL PROJECT_CF_KEY

project_version() {
  local sha
  if [[ -r "$PROJECT_VERSION_FILE" ]]; then
    cat "$PROJECT_VERSION_FILE"
  else
    sha="$(curl -fsSL --max-time 8 "${PROJECT_API_BASE_URL}/commits/${PROJECT_BRANCH}" 2>/dev/null | sed -n 's/.*"sha"[[:space:]]*:[[:space:]]*"\([0-9a-f]*\)".*/\1/p' | head -n 1 || true)"
    if [[ -n "$sha" ]]; then printf '%.7s\n' "$sha"; else git -C "$(dirname "${BASH_SOURCE[0]}")/.." rev-parse --short=7 HEAD 2>/dev/null || printf 'source\n'; fi
  fi
}
