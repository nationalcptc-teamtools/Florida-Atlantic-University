# Learning Write-up — First CPTC-style boxes: VMware setup, DC recon & null sessions
**Date:** 2026-10-26 → 2026-10-27 (late-night session, Fluffy on HTB + local VM setup)
**Machine context:** HTB AttackBox (us-dedivip-5 / 10.10.15.96) → target 10.129.232.88
**Status:** ACTIVE — recon done, first handholds unresolved, exploitation untouched (intentional)

---

## 1. Where this session fits

Purpose: begin CPTS prep (HTB Academy) on the CPTS Preparation machine list, feeding every
command/lesson into the CPTC team runbook (`~/Documents/Default Project/CPTC/`).
Prep context: CPTC12 SE Regional competition on 2026-11-07/08; UCI/RIT/Purdue (upd.) notes
and the CPTC12 Welcome Packet (Butters Family Farm, собакa VDI, password of the family firm; see
`study-roadmap.md`) shape the workflow this write-up trains.

---

## 2. Environment problems solved first

| Problem | Symptom | Root Cause / Fix |
|---|---|---|
| Mouse doesn't render inside Kali 2025.1a VMware VM, screen appears "zoomed out" | pointer invisible in guest; fixed low resolution; typing works | Missing **desktop tooling integration**: `sudo apt install -y open-vm-tools open-vm-tools-desktop` + rebootSUMMARY |
| Inputs not reaching the VM | bottom status bar says "To direct input to this VM … press Ctrl+G" | Normal VMware focus behavior: click into VM or **Ctrl+G**; release with **Ctrl+Alt** |
| Display looks small/lifeless | guest resolution fixed, autoplay-less | **View → Autofit Guest** + **Fit guest now**; fullscreen = **Ctrl+Alt+Enter**; snapshot a `00-baseline-tools` baseline right after |

Lesson: fix the environment FIRST, understand what VMware is telling you in its status bar,
before assuming the box/VM is broken.

---

## 3. Lesson 1 — there is no "connect" command

First reflex was to run `fluffy` as a shell command (it isn't). Machines are attacked **by
their IP** (shown in the HTB machine page "Connection" pane) — that IP is the only "handle."

---

## 4. Lesson 2 — `Host seems down` is a lie on Windows/AD targets

Recon started as:
```
nmap -sC -sV 10.129.232.88          → Note: Host seems down ... (0 hosts up)
nmap -sC -sV 10.129.232.88 -p-      → same failure in 3.13 s
```
Both look "dead" because nmap's first stage is a **ping sweep**, and Windows/AD boxes
rarely answer ICMP. The fix was in the error message itself:
```
nmap -Pn -sC -sV 10.129.232.88
```
`-Pn` = "treat as up, skip ping discovery." From now on, `-Pn` on every nmap run in this
course/competition (logged to `runbook/recon.md`).

---

## 5. What the DC scan revealed (and how to read it)

Quick pass returned:

```
53    domain           Simple DNS Plus
88    kerberos-sec     Microsoft Windows Kerberos (server time ...)
139   netbios-ssn
389   ldap             Microsoft Windows Active Directory LDAP (Domain: fluffy.htb0., ...)
445   microsoft-ds?
464   kpasswd5?
593   ncacn_http
636   ssl/ldap         (same LDAP banner + SSL cert SAN)
3268  ldap             (Global Catalog)
3269  ssl/ldap         (GC)
5985  http             Microsoft HTTPAPI 2.0  → WinRM
```

Key reads from banners (all free intel — no scanning tools needed):
- **It's a Domain Controller** (DC01): 88+389+636+3268+3269+464 together = the universal DC fingerprint
- Two name-freebies: LDAP banner gives **`fluffy.htb`** (domain); the SSL cert on 636/389 leaks
  **SAN: `DC01.fluffy.htb`, `fluffy.htb`, `FLUFFY-DC01? SNIP** — hostnames without any DNS enumeration
- **445 shows `microsoft-ds?`** (the `?` = nmap couldn't confirm; probe with a real SMB tool)
- **Host script results matter**: `smb2-security-mode → Message signing enabled and required`
  = SMB relay→this host says "no"; `SMBv1 disabled` = no legacy dialect nmap-visible
- **`+7h00m00s from scanner time` clock-skew warnings** = my box's clock is wrong vs the DC
  and Kerberos requires sync (`KRB_AP_ERR_SKEW` otherwise). Fix BEFORE any ticket work:
  `sudo ntpdate <DC IP>`
- **5985 = WinRM** — a *destination* to keep in mind for later shells
- Interesting *absences*: no 80/443 web on the quick pass (box story = pure directory attack), and 135
  (RPC endpoint mapper) missing = filtered from our vantage, not actually closed

Full table version lives in `runbook/recon.md` under "DC port fingerprint."

Setup applied after reading the scan:
```
sudo apt install -y ntpdate && sudo ntpdate 10.129.232.88
echo "10.129.232.88  DC01.fluffy.htb fluffy.htb" | sudo tee -a /etc/hosts
```

---

## 6. The anonymous-SMB chain (UCI/Purdue decision tree)

### 6.1 `nxc smb 10.129.232.88`
```
SMB   10.129.232.88 445 DC01   [*] Windows 10 / Server 2019 Build 17763 (name:DC01)
      (domain:fluffy.htb) (signing:True) (SMBv1:None) (Null Auth:True)
```
Reading the parentheticals: signing True + SMBv1 None = no relay, no legacy-entity; and
**Null Auth: True** — anonymous SMB sessions are accepted at the protocol layer.

### 6.2 `smbclient -L 10.129.232.88` (typed WITHOUT `-N` — pressed Enter on blank password → still worked)
```
ADMIN$  C$       Disk      (admin only — expected fail later)
IPC$    IPC
IT      Disk     ← custom, no comment — the odd one out
NETLOGON           Logon server share
SYSVOL             Logon server share
SMB1 disabled -- no workgroup available
```
Lesson: null share lists work; **always add `-N`** and not rely on blank-Enter luck.
`NETLOGON`/`SYSVOL` are default-readable (GPO/login scripts — GPP hunting turf per UCI notes);
`IT` is a non-default share — prime "fuel source" candidate.

### 6.3 `enum4linux-ng 10.129.232.88`
Useful half:
- Null session AND a guesst "random-name" session both accepted
- Domain info via SMB: DC01 / FLUFFY / fluffy.htb / FQDN DC01.fluffy.htb
- **Domain SID collected** (S-1-5-21-…) — keep for laterRID math
- RPC-visible OS merged: Server 2019 / 10.0 / build 17763
Hardened half (all `STATUS_ACCESS_DENIED`, normal on a tight DC):
- users via `querydispinfo` / `enumdomusers`
- group enums, shares via RPC, srvinfo, printers, policies
Conclusion: RPC user-enum is closed → the userlist must come from **another prong** (LDAP / Kerberos).

### 6.4 Dead ends (updated)
- ~~`ldapsearch 10.129.232.88` → `Can't contact LDAP server (-1)`~~ — **RESOLVED: pure syntax error.**
  The correct form worked immediately:
  `ldapsearch -H ldap://10.129.232.88 -x -s base namingcontexts`
  → anonymous bind succeeds; base DN = **`DC=fluffy,DC=htb`**, plus Configuration/Schema/DomainDnsZones/ForestDnsZones contexts.
- corrected-anon LDAP **object queries** + kerbrute userlist attempts: **still unresolved — revisit**
  (paths/commands saved here on purpose so this stays a documented dead-end, not a mystery)

---

## 7. The `IT` share — inside without a door handle

`ls` showed (top-level only): `Desktop / Downloads / Documents / Videos / Templates / my_data`
— a **user-profile-shaped** target, strongly implying it belongs to a specific human, not a service.
Every `cd` into those returned `NT_STATUS_ACCESS_DENIED`: root listable, contents not.
**Update (post-session check):** on a re-connect, even the root `ls` denied. So the successful root listing
was a time/connection-dependent window — access can vary per SMB session. Lesson: record observed
behavior with timestamps; a later denial doesn't erase what an earlier success taught us.

What that means, what it doesn't:
- ✅ We LEARNED the shape (this is a person's share; folder names captured)
- ✅ Informational-finding material (anonymous users see the layout)
- ❌ "Listing" ≠ "readable" — a dir-list grant is not a read grant. Moving on until a credential/handhold
  appears is the right call — record and exit.

---

## 8. Principles this session was actually about

1. **Attempt before assist** — 30–45 min solo before ANY hint; effort is the point.
2. **Log intent, not just commands** in `~/notes/<box>.md` (the AttackBox forgets everything).
3. **Every output feeds the runbook** — parentheticals, banners, denials are intel; commands go
   into the matching `runbook/*.md` after wrap-up.
4. **A denied request is a finding, not a failure** — record it, characterize the shape, move on.
5. **Fix the environment before blaming the target** (Mouse/zoom/focus were 3 problems, not 1).
6. **Reading >> running** — half of DC recon is interpreting nmap banners, host-script results,
   and enum tool phrasing, not firing more tools.

---

## 9. State at end of session (handoff notes)

- Fluffy: recon complete; null-session picture complete; user list pending; IT share blocked-on-purpose;
  exploitation not started (by design — the learning goal was recon hygiene)
- Runbook updated: `recon.md` (`-Pn` law, DC port fingerprint, per-service table rows),
  `ad.md` (flag gotchas: `dir /r`/ADS, FQDN host entries), `machines.md` (Fluffy row 🟨 + first section)
- Repo now also has: `study-roadmap.md` (CPTC→CPTS→CRTO sequence), `setup/install.sh` (our own
  minimal Purdue-style builder), `docker-compose.yaml` (practice Planka+CyberChef), MOST importantly:
  `purduestyle.md` deliberately kept as **adaptation notes**, not a copy-paste kit.

## 10. What runs next session (queued, not yet done)
1. Fix-then-retry: ntpdate → corrected `ldapsearch -H` anon bind → kerbrute userenum (document WHY each failed)
2. SYSVOL/NETLOGON structural pass (GPO/script inventory, `-N`)
3. First finding draft in Butters framing: "external DC exposes domain/SAN/IT-share layout via
   banners + anonymous SMB listing (Informational)"
4. Only after a handhold exists: pick the escalation prong from the UCI AD chain that matches
   what the deny/allow pattern actually says.
