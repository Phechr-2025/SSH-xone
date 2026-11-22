#!/usr/bin/env bash
SCRIPT_PATH="$(readlink -f "$0")"
ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
exec bash "$ROOT/update/udp-custom-menu.sh" "$@"
