# Purdue-style notes → what YOUR team adopts

Purdue (nationalcptc-teamtools/purdue-university) is the 2026-era team kit style: engineer the competition like a product.

## What "worth more than a repo full of scripts" means for us

### 1. One-script rebuild (setup/install.sh)
Their `setup.sh` + our adapted version: single command builds a full Kali attack box from zero.
Target: from bare Kali to fully tooled in under 30 min with no network fighting.
During the competition, when the Grad/track room gives you a fresh box, run it once and go.

### 2. Portable offline kit ("the folder you carry")
Because on-site (and often inside the VDI) network is restricted:
- winPEAS / linpeas
- pspy64/pspy64s
- ligolo-ng agent + proxy (BOTH linux + windows)
- chisel (BOTH linux + windows)
- nc64.exe
- MS Office/zip utilities, CyberChef binary
- Grep-or-sie geenraled wordlists you used in training (tiny subset only — do NOT steal/lift big dictionary files to carry; build one by hand from your training notes)

### 3. Shared team board (single source of truth during the event)
- One kanban board (Planka when practicing, or just a shared O365 planner inside Butters/O365 during the actual comp — no third-party SaaS).
- Same person owns "what's done / in-progress / no-results" — format the VDI's own notes doc that way.
- One shared evidence/notes web (their corkboard-style ingest: every nmap/nuclei/nxc run writes structured output, not chat spam).

### 4. Practice collab stack (docker-compose.yaml)
Planka (kanban) + CyberChef (local encode/decode) for team practice nights.
These *prove the workflow* internally; during the real CPTC you must use only Butters' provided O365/VDI environment.

### 5. AD-era chain (memorize — this is the "free vuln + escalation" core)
netexec → SMB share/anonymous + UAC
impacket  → mail, mssql linked, AS-REP/Kerberoast
certipy   → find vulnerable cert template ESCs
bloodyAD  → modify ACLS fast when you have rights (write access, add members, etc)
krbrelayx + PKINITtools → shadow credential path
bloodhound-ce-python → collect for the whole domain, upload to their self-hosted Bloodhound (or our FreeHound CE locally)

## Adoption priority for a new team
1. install.sh — build your first set of "boxes" for train nights next week
2. kit folder — build once
3. kanban/practice stack — start this second; even a shared MD file is enough
4. modern AD chain — netexec/certipy/krbrelayx/bloodhound
5. the rest — as CPTS modules train you
