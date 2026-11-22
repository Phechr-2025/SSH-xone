# SSH-one VPN Script

Fork-ready distribution based on the upstream `hop` script set. Project identity, update source, domain, and optional Cloudflare credentials are configured in `config.env`; edit those values in one place when you fork it. The previous hard-coded Cloudflare API keys and account emails were removed; Cloudflare automation needs `PROJECT_CLOUDFLARE_DOMAIN`, `PROJECT_CLOUDFLARE_EMAIL`, and `PROJECT_CLOUDFLARE_API_KEY` set there.

## Supported systems

- Debian 9, 10, and 11
- Ubuntu 18.04 and 20.04

Run on a clean VPS as root. Install the system packages and start the installer with one paste (change the first two values if your GitHub repository differs):

```sh
PROJECT_GITHUB_OWNER=Phechr-2025 PROJECT_GITHUB_REPO=SSH-xone PROJECT_GITHUB_BRANCH=main; apt update && apt install -y ca-certificates curl tar wget screen bzip2 gzip coreutils unzip && wget -qO /root/ssh-xone-install.sh "https://raw.githubusercontent.com/${PROJECT_GITHUB_OWNER}/${PROJECT_GITHUB_REPO}/${PROJECT_GITHUB_BRANCH}/install.sh" && sed -i 's/\r$//' /root/ssh-xone-install.sh && PROJECT_GITHUB_OWNER="$PROJECT_GITHUB_OWNER" PROJECT_GITHUB_REPO="$PROJECT_GITHUB_REPO" PROJECT_GITHUB_BRANCH="$PROJECT_GITHUB_BRANCH" bash /root/ssh-xone-install.sh
```

The repository must contain `config.env` and the scripts before running the command. For a local source checkout, run `bash install.sh` as root.

## Main menu

`menu` opens the 1–25 menu. UDP is option 1. `17. UPDATE SSH / MENU (Update)` downloads and replaces the complete project script tree from the configured GitHub repository; the previous tree is kept at `/opt/ssh-xone.previous`. `updatemenu` remains an alias for the same updater. The installed version shown in the menu is the short Git commit hash.

## UDP Custom

UDP Custom is provided as a separate service and account menu (`udp-menu`) and is also available from the main menu. It supports install/update, add/list/renew/delete accounts, connection information, service controls, and uninstall. Configure asset URLs, root directory, service name, group, and default listen port in `config.env`.

Review firewall rules and `udp/config.json` for the ports and behavior you intend to expose. The bundled third-party UDP executable is a prebuilt Linux amd64 binary and will not run on ARM or other architectures.

## Uninstall

Use `udp-menu` → `11` to remove UDP Custom, or run `uninstall-project` for the full script suite. The full remover asks for an explicit `REMOVE`, creates a timestamped archive under `/root`, leaves Linux accounts and shared packages intact, and keeps server data by default. Add `--purge-data` only when you also want those preserved VPN configuration directories removed after backup.

