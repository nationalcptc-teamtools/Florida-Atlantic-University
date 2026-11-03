# CPTS Preparation — Machine Tracker

Rules of engagement per box:
1. Attempt solo 30–45 min (no hints/modules).
2. Stuck → matching Academy module, THEN hints.
3. Both flags before wrap-up.
4. Wrap-up: runbook commands + Butters-client finding + 1-line post-mortem.

| Order | Box | OS / Diff | Status | User flag date | Root flag date | Key skills | Runbook file I fed | Post-mortem |
|---|---|---|---|---|---|---|---|---|
| 1 | Trick | Linux / Easy | ⬜ todo | | | | | |
| 2 | Postman | Linux / Easy | ⬜ todo | | | | | |
| 3 | Jeeves | Windows / Medium | ⬜ todo | | | | | |
| 4 | Fluffy | Windows / Easy | 🟨 in-progress 2026-10-26 | | | recon (nmap -Pn lesson) | recon.md | |
| 5 | Pov | Windows / Medium | ⬜ todo | | | | | |
| 6 | TombWatcher | Windows / Medium | ⬜ todo | | | | | |
| 7 | Media | Windows / Medium | ⬜ todo | | | | | |
| 8 | VulnCicada | Windows / ? | ⬜ todo | | | | | |

> 2026-10-26: **Fluffy started out of order** (we picked it up first). That's fine — this tracker's order is a suggestion, the wrap-up rules are not.

## Status legend
⬜ todo · 🟨 in-progress · ✅ fully wrapped (tracker row complete)

## Per-box mini-write-up sections (paste under here per box, as you go)
### Fluffy (in-progress 2026-10-26/27)
**What it taught me:**
- First real DC scan: read nmap parentheticals as intel (signing/SMBv1/Null helped shape the plan)
- Null session accepted → branch: anon SMB = fuel source
- `smbclient -L` without `-N` still worked with a blank Enter password (null session) — but always type `-N`
- `enum4linux-ng` collected domain info + Domain SID but AD user enum via RPC denied (hardened DC) → need userlist from another prong
- `ldapsearch host` alone is a syntax error → must use `-H ldap://<IP> -x -s base namingcontexts`
**Key outputs:**
- DC01.fluffy.htb, domain fluffy.htb, Server 2019 build 17763, signing required, SMB1 disabled
- Custom share `IT` exists — user-profile-shaped (`Desktop/Downloads/Documents/Videos/Templates/my_data`, captured in successful early root `ls`). Later attempts: **root `ls` also denied**. ACL behavior varied between connections — log timelines, not snapshots. Gated on creds either way.
- Domain SID: S-1-5-21-...-2627064577 (keep for RID math)
- kerbrute userenum (xato sorted-unique) works unauthenticated: first hit `Administrator@fluffy.htb` (expected built-in — proves pipeline; real names come from deeper in the list)._hits are case-duplicated → lowercase+`sort -u` into users.txt
- SYSVOL & NETLOGON anonymous: smbclient connects but `ls` → `NT_STATUS_ACCESS_DENIED` (anonymous ≠ Everyone on hardened DCs; prong closed until credentials exist)
- **Kerbrute sweep COMPLETE:** 624,370 names tested, only built-ins valid (Administrator + Guest, case-variants). `-dup` seclists file ≈ 624K names, NOT the full 10M xato → full list needed before concluding "no themed users."
**Post-mortem (fill at wrap-up):**
- Open gaps after day 1: (1) ~~full `-p-` port sweep never run~~ **DONE 10/27** — only 9389/ADWS + standard 496xx RPC band added, no surprise apps, 135 still filtered from vantage; (2) full xato list not yet tested; (3) ntpdate/clock sync never confirmed. Exploit-feasibility: none yet — expected cumulative-gaps state, not a dead end.

### Trick
**What it taught me:**
**Commands I actually used (goes in runbook too):**
**Post-mortem:**


