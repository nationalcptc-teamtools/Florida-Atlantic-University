#!/usr/bin/env bash
# CPTC team attack-box installer — Kali Linux amd64
# Modeled on the perdue/teamtools approach: one script, zero dead time.
# Run: ./install.sh            (core toolkit)
#      ./install.sh --services (core + docker collab stack for PRACTICE sessions)
#      ./install.sh --kit      (core + portable offline kit fetch)
set -euo pipefail

mode_services=false; mode_kit=false
for arg in "${@:-}"; do
  case "$arg" in
    --services) mode_services=true ;;
    --kit)      mode_kit=true ;;
    *) echo "Usage: $0 [--services] [--kit]" >&2; exit 2 ;;
  esac
done

# --- environment guards -------------------------------------------------------
source /etc/os-release
[[ "$ID" == kali && "$(uname -m)" == x86_64 ]] || { echo 'Run this on Kali Linux amd64.' >&2; exit 1; }
[[ "$EUID" -ne 0 ]] || { echo 'Run as your normal user; package installs use sudo.' >&2; exit 1; }

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
data=${TEAMTOOLS_HOME:-$HOME/.local/share/teamtools}
data=$(realpath -m "$data"); bin=$HOME/.local/bin
export TEAMTOOLS_HOME="$data"; export PATH="$bin:$PATH"; export GOBIN="$bin"
mkdir -p "$data/src" "$data/tools" "$bin"

echo "[*] Phase 1/4 — packages"
sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates curl git unzip jq build-essential golang-go \
    python3-venv python3-dev pipx \
    nmap smbclient ldap-utils dnsutils snmp onesixtyone rpcbind nfs-common \
    default-mysql-client postgresql-client \
    krb5-user proxychains4 socat netcat-openbsd \
    hashcat john wordlists seclists \
    enum4linux-ng responder mitm6 \
    chromium gowitness nuclei ffuf feroxbuster whatweb sqlmap rustscan \
    tmux perl ruby-dev libkrb5-dev libreadline-dev freerdp3-x11 \
    oathtool mono-devel docker.io docker-compose

echo "[*] Phase 2/4 — pipx tools (modern AD + web chain)"
pipx_install() { command -v "$1" >/dev/null 2>&1 || pipx install "$2"; }
pipx_install nxc                "git+https://github.com/Pennyw0rth/NetExec.git"
pipx_install secretsdump.py     impacket
pipx_install certipy            certipy-ad
pipx_install bloodyAD           bloodyAD
pipx_install bloodhound-ce-python bloodhound-ce
pipx_install git-dumper         git-dumper
pipx_install dirsearch          dirsearch
pipx_install manspider          man-spider
pipx_install targetedKerberoast targetedKerberoast
pipx_install sstimap            sstimap

echo "[*] Phase 3/4 — source-cloned & go tools"
clone() { [[ -d "$data/src/$2/.git" ]] || git clone --depth 1 "https://github.com/$1.git" "$data/src/$2"; }
clone dirkjanm/krbrelayx      krbrelayx
clone dirkjanm/PKINITtools    gettgtpkinit
clone gpakosz/.tmux           oh-my-tmux

command -v kerbrute >/dev/null 2>&1 || go install github.com/ropnop/kerbrute@v1.0.3
command -v evil-winrm >/dev/null 2>&1 || sudo gem install evil-winrm --no-document

echo "[*] Phase 4/4 — portable binaries you redistribute onto targets"
fetch() { local t; t=$(mktemp "$data/tools/.dl.XXXXXX"); curl -fL --retry 3 "$1" -o "$t" && mv "$t" "$2" || { rm -f "$t"; echo "  ! failed: $1 (skipped — update URL or grab manually)"; }; }
fetch https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64      "$data/tools/pspy64"
fetch https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64s     "$data/tools/pspy64s"
fetch https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh    "$data/tools/linpeas.sh"
fetch https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe "$data/tools/winPEASx64.exe"
fetch https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_agent_0.8.2_linux_amd64.zip      "$data/tools/ligolo-linux.zip"
fetch https://github.com/nicocha30/ligolo-ng/releases/download/v0.8.2/ligolo-ng_agent_0.8.2_windows_amd64.zip    "$data/tools/ligolo-windows.zip"
fetch https://github.com/jpillora/chisel/releases/download/v1.10.1/chisel_1.10.1_linux_amd64.gz  "$data/tools/chisel-linux.gz"
fetch https://github.com/jpillora/chisel/releases/download/v1.10.1/chisel_1.10.1_windows_amd64.exe.gz "$data/tools/chisel-windows.gz"

# tmux config (oh-my-tmux, Purdue-style)
if [[ -e "$HOME/.tmux.conf" || -L "$HOME/.tmux.conf" ]]; then
  mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.$(date -u +%Y%m%dT%H%M%S).bak"
fi
ln -sfn "$data/src/oh-my-tmux/.tmux.conf" "$HOME/.tmux.conf"
[[ -e "$HOME/.tmux.conf.local" ]] || cnf=${XDG_CONFIG_HOME:-$HOME/.config}/tmux; mkdir -p "$cnf" 2>/dev/null || true

chmod +x "$data/tools/"* 2>/dev/null || true

if $mode_kit; then
  echo "[*] extra kit: SharpHound + out-of-band file-drop binaries"
  fetch "$(curl -fsSL https://api.github.com/repos/SpecterOps/SharpHound/releases/latest | jq -er '[.assets[] | select(.name | test("windows_x86.zip")) | .browser_download_url] | .[0]')" "$data/tools/sharphound.zip"
  unzip -o "$data/tools/sharphound.zip" -d "$data/tools/sharphound" && rm "$data/tools/sharphound.zip"
  fetch https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat "$data/tools/winPEAS.bat"
fi

if $mode_services; then
  echo "[*] practice collab stack (kanban + local CyberChef)"
  sudo systemctl enable --now docker 2>/dev/null || true
  (cd "$root" && sudo docker compose -f docker-compose.yaml up -d)
fi

echo
echo "Done. Tools dir: $data/tools"
echo "PATH additions:  export PATH=\"$bin:\$PATH\""
echo "The kit folder to carry: $data/tools  (winPEAS/linpeas/pspy/ligolo/chisel)"
