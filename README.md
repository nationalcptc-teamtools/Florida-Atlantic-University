# CPTC Team Runbook

Starter repo structured after the UC Irvine (checklists/reporting) and RIT (setup/scripts) competition repos.
The point: by competition day this folder is muscle memory — every command verified by YOU during training.

## Layout

- `runbook/` — one cheat-sheet per domain. Fill these from HTB Academy while you learn (start empty, finish filled).
- `drills/` — timing drills and practice routines.
- `setup/` — **your attack-box installer.** `setup/install.sh` builds a full Kali box from zero (Purdue-style, adapted). `--kit` also fetches the portable "carry folder" binaries (peass/pspy/ligolo/chisel), `--services` also starts the practice collab stack (kanban + local CyberChef). See `setup/purduestyle.md` for the philosophy.
- `notes/` — reference notes extracted from other teams (UCI + RIT) live in `UCI-notes/` next to this.

## The session layout (what should be open while working an HTB box)

**Browser:** Academy module page (you're working) + machine "Connection" page (IP/timer).
**Kali VM, tmux:** left pane = working shell; right-pane split = target shell/listiner when you have it; bottom strip = logs/listener. Save session log: `~/notes/<box>.md` — log every command's *intent* there, then copy winners to the runbook after.
**Editor, two files:** the runbook section you're filling (`runbook/<file>.md`) + `machines.md`.

**Wrap-up checklist (10 min, every session):**
1. `machines.md` row updated (status/date/post-mortem)
2. commands copied from VM session log → the matching `runbook/*.md`
3. one finding written in Butters-family framing
4. VM snapshot saved (baseline first: `00-baseline-tools`)

**AttackBox vs local VM:** AttackBox is fine for early modules but persists nothing — the copy-out habit is non-negotiable there. Switch to your own Kali VM by the pivoting/AD modules; CPTC gives you BYOD + VDI, so your own box is the only honest rehearsal. (VMware basics: Autofit Guest fixes the "zoomed out" view; `open-vm-tools open-vm-tools-desktop` fixes mouse/resolution if missing; snapshot early, snapshot often.)

**GOAD note:** the Game of Active Directory lab you have provisioned is a great *later-stage* AD dress rehearsal (BloodHound → ACL/cert paths → escalation in a painted domain). Suspend it while doing single-target Academy work — it's heavy.

## The golden rule

After every HTB Academy module / lab / box you finish, write in this repo:

1. Every command you actually used (copy from YOUR history, not the academic pages).
2. What to try first the next time you see this service/OS.
3. The "free vuln" — any scoring finding you could report from this work.

Not the textbook's commands — yours. That difference is why UCI/RIT notes work: they are distilled from reps.

## Order of study (mirrors the backbones of CPTS)

1. Footprinting → `runbook/recon.md`
2. Web (checklist-style) → `runbook/web.md`
3. Pivoting → `runbook/pivoting.md`
4. Windows privesc → `runbook/windows-privesc.md`
5. Linux privesc → `runbook/linux-privesc.md`
6. Active Directory → `runbook/ad.md`
7. Report writing drill → `drills/report-drill.md`

## Competition facts to remember (CPTC12 SE, Nov 7-8)

- 8 h on-site; report due 11:59 pm the same night. Outline the report at hour 5 — not hour 11.
- Work ONLY inside provided VDI + their O365 tenant. No third-party tools/drives/chat.
- Client: Butters Family Farm. Framing in the report = business impact for expansion/investors.
- Read scope/out-of-scope before touching anything. Scope discipline is scored.
- Known-dead ends: VDI, VPN, LaForge, SplunkUniversalForwarder, O365.
