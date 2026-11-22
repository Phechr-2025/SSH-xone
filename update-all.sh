#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root.' >&2; exit 1; }
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
. "$SCRIPT_DIR/lib/project.sh"
command -v curl >/dev/null && command -v tar >/dev/null || { echo 'Install curl and tar first.' >&2; exit 1; }
parent="$(dirname "$PROJECT_ROOT")"
stage="$(mktemp -d "$parent/.${PROJECT_NAME}.update.XXXXXX")"
trap 'rm -rf -- "$stage"' EXIT
echo "Downloading ${PROJECT_OWNER}/${PROJECT_NAME}@${PROJECT_BRANCH} ..."
curl -fL --retry 3 --connect-timeout 15 "$PROJECT_ARCHIVE_URL" -o "$stage/source.tar.gz"
tar -xzf "$stage/source.tar.gz" -C "$stage"
source_dir="$(find "$stage" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | head -n 1)"
[[ -n "$source_dir" && -f "$source_dir/setup.sh" && -f "$source_dir/update/menu.sh" ]] || { echo 'Downloaded archive is not a valid project release.' >&2; exit 1; }
install -d -m 0755 "$PROJECT_ROOT"
if [[ -f "$PROJECT_CONFIG" ]]; then install -m 0600 "$PROJECT_CONFIG" "$source_dir/config.env"; fi
old="${PROJECT_ROOT}.previous"
rm -rf -- "$old"
[[ ! -e "$PROJECT_ROOT" ]] || mv "$PROJECT_ROOT" "$old"
mv "$source_dir" "$PROJECT_ROOT"
install -d -m 0755 "$PROJECT_CONFIG_DIR"
install -m 0600 "$PROJECT_ROOT/config.env" "$PROJECT_CONFIG"
commit="$(curl -fsSL "${PROJECT_API_BASE_URL}/commits/${PROJECT_BRANCH}" | sed -n 's/.*"sha"[[:space:]]*:[[:space:]]*"\([0-9a-f]*\)".*/\1/p' | head -n 1 || true)"
printf '%s\n' "${commit:0:7}" > "$PROJECT_VERSION_FILE"
for f in menu udp-menu updateall; do :; done
ln -sfn "$PROJECT_ROOT/update/menu.sh" /usr/bin/menu
ln -sfn "$PROJECT_ROOT/udp/menu.sh" /usr/bin/udp-menu
ln -sfn "$PROJECT_ROOT/update-all.sh" /usr/bin/updateall
ln -sfn "$PROJECT_ROOT/uninstall.sh" /usr/bin/uninstall-project
ln -sfn /usr/bin/updateall /usr/bin/updatemenu
chmod +x "$PROJECT_ROOT/update/menu.sh" "$PROJECT_ROOT/udp/"*.sh "$PROJECT_ROOT/update-all.sh"
chmod +x "$PROJECT_ROOT/uninstall.sh"
echo "Updated all project files from ${PROJECT_OWNER}/${PROJECT_NAME}. Previous version: $old"
