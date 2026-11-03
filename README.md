# CPTC Team Runbook

Starter repo structured after the UC Irvine (checklists/reporting) and RIT (setup/scripts) competition repos.
The point: by competition day this folder is muscle memory — every command verified by YOU during training.

## Layout

- `runbook/` — one cheat-sheet per domain. Fill these from HTB Academy while you learn (start empty, finish filled).
- `drills/` — timing drills and practice routines.
- `setup/` — **your attack-box installer.** `setup/install.sh` builds a full Kali box from zero (Purdue-style, adapted). `--kit` also fetches the portable "carry folder" binaries (peass/pspy/ligolo/chisel), `--services` also starts the practice collab stack (kanban + local CyberChef). See `setup/purduestyle.md` for the philosophy. `setup/tmux-keys.sh` adds keyboard shortcuts to tmux — run once on any attack box and read the explanation below.
- `scripts/` — host-side tools you run **on a machine you're standing in** (enumeration only, no changes made to targets). `scripts/local-linux-enum.sh` (credited to UCI CCDC) prints a full Linux host inventory in one shot: hostname/IP/user, listening ports + PIDs, Docker containers (running AND stopped), human + sudo users, domain-join status via `/etc/krb5.conf`, fstab mounts, service-tied processes, Kubernetes role, and which known services are installed (web/mail/DB/VPN/monitoring/PHP everywhere). First command to run after landing on a Linux box — its output is a report-ready picture and tells you which of your other playbooks apply (see `runbook/linux-privesc.md`).
- `notes/` — reference notes extracted from other teams (UCI + RIT) live in `UCI-notes/` next to this.

### tmux quick-keys (`setup/tmux-keys.sh`)

Why this matters on competition day: the session layout (below) only works if you can move between
"scan window / working shell / logs window" fast enough to keep notes alive. tmux's defaults make you
type prefix-key-and-Arrow to switch windows, which is slow and makes logging a chore — and an unlogged
session is losing the report its evidence.

Running it once (inside tmux) writes to `~/.tmux.conf`:

| Key | Effect |
|---|---|
| `Alt+1` … `Alt+9` | jump straight to tmux window 1–9 — no prefix key |
| `Alt+g` | open a new window (it's named `M-g`, "**g**o make one") |

Details baked into the script:
- **Idempotent:** greps `.tmux.conf` first — running it twice won't duplicate bindings.
- **Wins vs. losing bindings:** appends don't override anything you already customized.
- Run it on every fresh attack box. `Alt+N` then becomes part of the logged workflow:
  `Alt+1` = scans and sweeps, `Alt+2` = working shell + `tee`d logs, `Alt+g` = the listener,
  and the bottom-left `[enum] 0:kerbrute*` strip you already use on Fluffy stays visible in all of them.

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
