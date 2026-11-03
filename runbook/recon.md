# Recon Runbook (fill during CPTS Footprinting/Enumeration modules)

## Host discovery
```
# (fill in after you learn it: your actual discovery sweep)
```

## Port scan progression (fast → complete)
```
# 1. quick pass (default 1000 ports) — ALWAYS with -Pn on Windows/AD targets:
nmap -Pn -sC -sV <IP>
# 2. full TCP sweep (slow, run in a tmux window in background):
nmap -Pn -p- -sC -sV <IP>
# 3. follow-up deep-dive on interesting ports only:
nmap -Pn -p <ports> -A <IP>
# 4. UDP top ports (later, once TCP is mapped):
nmap -Pn -sU --top-ports 50 <IP>
```

## Lessons from the first real session (2026-10-26)
- **`Host seems down` = lie.** Windows/AD boxes rarely answer ICMP. `-Pn` first, ALWAYS.
- Machines have no "connect command" — you attack **by IP**. The IP on the machine page, and nmap, is all you type.
- Sanity checks before scanning: machine shows **Active / timer running** on the HTB page, and the IP matches what you're scanning (resets change it).
- If the quick pass shows few ports, that's normal on AD boxes — the story usually starts at one or two services. GO wide, GO deep, don't panic.
- Optional: once DNS names surface, add them to `/etc/hosts` (`<IP> hostname.domain`) — Kerberos tools will want the FQDN.

## Per-service one-liners — add as you meet each service
| Port | What to run first | Free-vuln angle |
|---|---|---|
| 21 ftp | | |
| 22 ssh | | |
| 25 smtp | *see UCI Mail notes* | TLS <1.3 via sslscan |
| 80/443 http | | |
| 88 kerberos | *always alongside other AD ports; no direct recon tool* | ticket attacks need handholds (creds/users) first |
| 139/445 smb | `nxc smb <IP>` then `smbclient -L //<host>/ -N` then `enum4linux-ng -A` | anonymous access — instant finding; also check `smb2-security-mode` in nmap output: signing ENABLED = relay dead, signED-disabled = record it |
| 1433 mssql | | |
| 3306 mysql | | |
| 3389 rdp | | |
| 389/636/3268/3269 ldap | `ldapsearch -H ldap://<IP> -x -s base namingcontexts` anonymous bind | anonymous bind / password-not-required attrs (UCI ldap.txt) |
| 53 dns | `dig @<IP> fluffy.htb ANY` + SRV queries when domain known | zone transfer (rare but juicy); anonymous SRV/A record dumps |

## DC port fingerprint (from Fluffy scan, 2026-10-26) — commit to memory

ALL of these together = **Domain Controller**. Sub-set (e.g. 88+445+389 partial) = member server/AD object.

| Port | Service | What it is in AD | Why it matters to you |
|---|---|---|---|
| 53 | DNS | AD's resolver — lives ON the DC. Clients find services via SRV records here | anonymous queries can dump SRV/A records → free server inventory, no creds |
| 88 | Kerberos | ticket server (KDC) — issues TGT/TGS | every ticket attack (roasting, delegation, PtT) talks here |
| 139 | NetBIOS | legacy session service, old SMB's half | tells you "Windows target," little else beyond 445 |
| 445 | SMB | modern file/RPC shares, named pipes | THE AD filesystem door: enum, psexec, staging, spraying |
| 389 | LDAP | directory query port | anon or authed enum, attribute hunting, RID cycling |
| 464 | kpasswd | Kerberos password-change service | normal on a KDC; some relay/change tools use it |
| 593 | RPC over HTTP | RPC tunneled over HTTP (ncacn_http) | usually background infra, rarely first target |
| 636 | LDAPS | LDAP over TLS | same queries, encrypted; cert SANs leak hostnames — free recon |
| 3268 | Global Catalog | FOREST-wide database (all domains) | multi-domain CPTC nets: forest perspective lives here |
| 3269 | GC over TLS | GC + TLS | same as 3268 |
| 5985 | WinRM | PowerShell remoting door | with a valid password OR NT hash → evil-winrm destination |

**Runbook notes from the DC-port analysis:**
- **135 (RPC endpoint mapper) missing** on the Fluffy scan = filtered from our vantage, NOT missing in reality. Don't panic; document and probe later.
- **No 80/443 web** on the Fluffy quick pass = the box's story is pure directory — the attack surface *is* the domain.
- **Clock skew warning in nmap output** (`+7h...`) = fix with `sudo ntpdate <DC-IP>` BEFORE any Kerberos work; tickets die on skew (`KRB_AP_ERR_SKEW`).
- **`445 microsoft-ds?` with a question mark** = nmap couldn't confirm; always follow with a real SMB tool before assuming.
- **`464 open` = normal on DCs**, not a special finding — but confirms Kerberos toolkit is fair game once handholds exist. |

## Subnet sweep (the RIT way)
```
# add your masscan/approved full-range command here
```

## Installing a quick tool (kerbrute, Kali/AttackBox)
```
# Option 1 — Kali's own package (try first, it's instant):
sudo apt update && sudo apt install -y kerbrute
# verify:
kerbrute -h
```
```
# Option 2 — prebuilt binary from GitHub releases (if repo version is missing/old):
wget https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_linux_amd64 -O kerbrute
chmod +x kerbrute && ./kerbrute -h
```
```
# Option 3 — from source (needs go, how your install.sh builds it for stance):
GOBIN=~/.local/bin go install github.com/ropnop/kerbrute@v1.0.3
```
Note: repos ship old versions — if `kerbrute userenum` misbehaves, fall back to Option 2.
**2026-10-26 (HTB AttackBox):** Option 1 (apt) didn't have the package → Option 2 (GitHub release binary) worked. On competition boxes, expect this pattern often — solutions live in your carry-folder, not apt.

## Full-sweep delta reading (2026-10-27, Fluffy) — the "extra ports" decoder

When a full `-p-` finishes, sort every new line into 3 buckets instead of googling each:
1. **Noise:** `49667-49747` band = dynamic RPC endpoint listeners — every Windows service grabs one at boot. Universal, ignore. (Reason 135's endpoint mapper is the only RPC door that matters.)
2. **New interface:** `9389/tcp adws` = Active Directory Web Services (SOAP; the PowerShell AD module talks here). Directory interface #3 — LDAP-identical credentials, alternate path when LDAP is filtered/policed.
3. **Notable absence:** `135 filtered` from external vantage → blind RPC binds need known UUIDs. Vantage-dependent — an internal pivot position may see it fine; record per observation point.

And silence on web ports in a full sweep + AD fingerprint = **the domain IS the attack surface.**

## Priority triage spiral (REBUILT from UF `cptc-triage.sh` — their philosophy, our voice)

Run this ONCE per network/range, top-down, before any rabbit hole. Log everything —
each row you clear is either a table row in the report (finding or "tested, clean") or
a decision already made.

1. **Alive:** `nmap -sn <range> -oG out/alive.gnmap` — if empty, remember the law: `-Pn` and scan anyway.
2. **Services:** `nmap -Pn -sV -sC --open <range> -oA out/triage` → let it cook in tmux.
3. **Priority chase order** (highest-leverage services first, matches our per-service table):
   - **SMB (445):** `nxc smb <IP>` → null session & shares & signing flags (the IT-share lesson lives here)
   - **DC fingerprint (88+389+3268...):** domain from banners/cert SAN → anonymous prongs board (LDAP rootDSE → shares → kerbrute userenum; escalation needs a handhold)
   - **Mail (25/587/993):** Exchange-proxy CVEs on-prem; M365 → user-enum + spray
   - **DNS (53):** AXFR attempt + anonymous SRV/A dump (free server inventory)
   - **Web (80/443/8080/3000/5000/7000):** dir-brute → weak/default login creds → proxy API for IDOR/authz/hardcoded-JS secrets → SSRF on URL/image fetchers
   - **FTP (21):** anonymous banner read
   - **Databases (1433/3306/5432):** default creds first, second-thought actions only
   - **3389/5985:** *destinations* — note, return when creds exist
4. **Non-standard ports = the gold.** Anything outside the known list: `grep` it out of the
   gnmap, `nc` it, read the banner/menu, and hypothesize **command injection on custom
   in-house tools before anything else**. Custom code is written by the client's devs,
   under deadline — it's where a comp is won.
5. **After the spiral only:** pick lanes, start per-host deep-dives, start the report's inventory as you go.
