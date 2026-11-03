# UF teamtools digest (nationalcptc-teamtools/University-of-Florida)

**Source:** `C:\Users\roblo\Downloads\University-of-Florida-main\` (downloaded 2026-11-01)
**Key fact:** UF competes in the **same SE regional** as us → their kit is themed for the
same client (Butters Family Farm) and same dates (2026-11-07/08). This is the closest
reference repo we have — closer than UCI (older generation) or Purdue.

---

## What we copied into our repo

`CPTC\report-generator\` — the full **CPTC-Report-Generator** (cptc2027 version), plus
`CPTC\report-generator\injects-bff\` — UF's BFF inject-response templates.

## The CPTC-Report-Generator (their flagship)

**What it is:** a local Flask web app where the whole team logs findings *during* the comp,
with live CVSS calc, per-field rich text, image upload, and a one-click LaTeX export.

**Architecture (worth understanding, not just running):**
- `app.py` — Flask + waitress server on **0.0.0.0:5001** (LAN-shareable, team can hit it from the attack box browsers)
- Findings = folders of plain `.txt` files (`details.txt`, `confirmation.txt`, `impact.txt`,
  `mitigation.txt`, `references.txt`, `cvs.txt`, `ips.txt`) — **git-reviewable, grep-able, no lock-in**
- `prewrites/` — **33 pre-drafted findings** (see below). Load one → all five fields populate → edit for the specifics
- `generate_report.sh` — converts everything to LaTeX (needs `xelatex` + `jq`); output goes
  to a folder for **Overleaf** rendering → PDF
- Also tracks: overview page (exec summary, scope, AI-workflow/efficacy — CPTC asks for this),
  inventory (per-IP JSON), fileshare (evidence drops), appendix (tools used)

**Run it:**
```bash
python3 app.py            # needs flask, waitress (pip install flask waitress)
# browser: http://<attackbox-ip>:5001
./generate_report.sh      # after findings are done; needs xelatex + jq
```

**The prewrites list IS a study syllabus.** Every folder name = a finding class a SE team
expects to re-encounter. Study them *as technique vocabulary* long before Nov 7:

AdminLeakedCreds, ASREPRoasting, BrokenAccessControl, ClientSideAdminAuth, CSRF,
DefaultCredService, IDOR, InsecureAdminPanel, LFI, MissingSRI, NTLMv1, OpenSMBShare,
OutdatedService, OutdatedSSHCVE, PHPInfo, SQLi, XSSInjection, UnauthAPIendpoint,
JellyfinRevShell, JellyfinUnauthLogin, NetLogonEnabled, noAntivirus, weakDomainPassPolicy,
WinFirewall, UtilmanBackdoor, passwd, rootlogin, shadow, suid, sudoers, privatekeys,
OutdatedService, ZoneTransfer.

→ Cross-reference with `UCI-notes\free-vulns.txt` and our `drills\report-drill.md`
(prewrites = pre-drafted **findings**; our drill covers the **full report skeleton**).

## The BFF inject kit (`injects-bff/`)

`bff.sty` + `inject-response.tex` + docx templates — a complete LaTeX inject-response
template **already themed for Butters Family Farm / Southeast-# / Q4 2026 engagement**:
title block, memo header (To: Robin McGrass), "Request as Understood" section, bottom-line
callout, Actions-Taken with verification step, evidence-log appendix, confidentiality banner.

Why this matters: inject scoring rewards professional output *fast*. This is a fill-
in-the-structure scaffold, not content — using it = instant polish. Compiles with XeLaTeX.

## recon-toolkit (2027, left as reference — copy selectively)

- `cptc-triage.sh <range>` — excellent **network triage priority spiral**: alive sweep →
  `nmap -sV -sC --open` → per-service hit list (mail/SMB/FTP/DNS-AXFR/web/DC/DB/RDP/WinRM)
  **+ section 4: non-standard ports = "the gold" → banner+menu+cmd-injection**
- `cptc-enum.sh` (Linux host enum), `cptc-winenum.ps1` (Windows), `cptc-web.sh <url>`
- `setup.sh` — tool installer

## portinventory (2026, synergy with our Purdue setup)

`nmapxmlingest.py` + `plankainit/upload.py` — pushes nmap XML results onto a **Planka
kanban board** (one card per host/port). We already spin up Planka in
`setup\docker-compose.yaml` — wiring nmap XML→Planka is an upgrade path for team-wide
port visibility.

## asciinema + asciinemad

Session recording (.cast) with timestamped prompts — the "prove what we did" habit; their
docker server (`cptc2026-tools/asciinemad/docker-compose.yml`) replays casts for the report.

---

## Suggested adoption map

| Piece | Adopt level | Status 2026-11-01 |
|---|---|---|
| Report-Generator + prewrites | **Full** — copied in; test-drive this week | ✅ copied, untested |
| injects-bff templates | **Full** — copied in | ✅ copied + REBUILT as markdown drill in `drills\report-drill.md` |
| cptc-triage.sh priority spiral | Study + steal the *checklist* | ✅ REBUILT into `runbook\recon.md` "Priority triage spiral" |
| portinventory→Planka | Optional upgrade to our docker-compose kit | ⏳ not built — needs admin creds/config; do when the team commits to the kanban workflow |
| asciinema | Habit suggestion only | note only |
| Full-sweep port decoder | — | ✅ REBUILT into `runbook\recon.md` "Full-sweep delta reading" |
