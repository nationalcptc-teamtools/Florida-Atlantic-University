<<<<<<< HEAD
=======
im upset
---

>>>>>>> 6381c952b0e7f1e5f8034f0708c93b1f276d5138
# Web Vuln Runbook — CPTC

**Doctrine: collect with scripts, exploit by hand.**
Scripts find attack surface. Exploitation (hydra, sqlmap, privesc) is a
deliberate step **after** reading the results — never fired blind.

<<<<<<< HEAD
## Setup (fresh VM)

```bash
sudo ./install.sh              # full tool install (~30-60 min, see file header for flags)
sudo ./install.sh --dry-run    # just check package/URL resolution, install nothing
sudo ./install.sh --hardening  # only the defensive batch (auditd, rkhunter, fail2ban...)
```

Notes:
- one bad apt name never kills the run — failures logged to `install-fails.txt`
- GitHub-only binaries (linpeas/winpeas/pspy64/SharpHound/chisel/ligolo/PowerView)
  land in `~/tools/`, `~/tools/windows/`, `~/tools/powershell/`
- neo4j + xrdp need one manual config line each — the installer prints them at the end

## Run everything from one toolkit folder

```bash
cd <wherever you cloned>/parkershit/cptc2026
```

> Scripts write `loot/` relative to your current directory — running from
> `$HOME` scatters evidence you'll need for the report.

=======
## Setup

```bash
# One toolkit dir per box; all loot lands under ./loot/
git clone <team-repo-url> wp && cd wp   # or copy the folder however you got it
```

> **Run everything from inside the toolkit folder.** Scripts write loot
> relative to your current directory — running from `$HOME` scatters
> results you'll need for the report.

Requirements (both are on standard Kali/Pentest images):

```bash
command -v nmap whatweb ffuf python3   # all four should print
ls /usr/share/seclists/Discovery/Web-Content/common.txt || echo "get seclists!"
```

>>>>>>> 6381c952b0e7f1e5f8034f0708c93b1f276d5138
## Script 1 — recon sweep (every target, first)

```bash
echo y | ./web-recon.sh <ip>
```

The `echo y |` confirms the target is in scope at the script's gate —
<<<<<<< HEAD
only pass it for IPs the ops console / ROE brief lists.

| Step | What happens |
|------|--------------|
| 1 | nmap top-1000, service detect (`-sT`, NAT/VM-safe) |
| 2 | whatweb fingerprint of every web service |
| 3 | wafw00f — does the target fight back? |
| 4 | classic exposures: `/.git/HEAD`, `/.env`, robots, admin paths |
| 5 | ffuf dir-bust of every web port + readable `ffuf-summary.txt` |
| 6 | nuclei known-vuln scan |

**After every run, read three files:**

```bash
cat loot/<ip>-*/ffuf-summary.txt loot/<ip>-*/whatweb.txt loot/<ip>-*/quick-wins.txt
```

Exposed `/.git/`? The next move is already written into `quick-wins.txt`:

```bash
git-dumper http://<ip>/.git/ loot/git-dump/   # needs: pipx install git-dumper
grep -riE 'pass|key|secret|token|flag' loot/git-dump/ | head -50
=======
only do it for IPs the ops console / rules-of-engagement brief lists.

| Step | What happens |
|------|--------------|
| 1 | nmap top-1000 ports, service detection (`-sT`, WSL/VM-safe) |
| 2 | whatweb fingerprint of every web service found |
| 3 | classic exposures: `/.git/`, `/.env`, `robots.txt`, admin paths |
| 4 | ffuf dir-bust of each **web** port only |
| 5 |everything parsed into `loot/<ip>-MMDD-HHMM/` + readable `ffuf-summary.txt` |

### Read the loot

```bash
cd loot/<ip>-*/
cat ffuf-summary.txt whatweb.txt quick-wins.txt
cd ../..
```

Example of a real result worth noticing:

```
=== ffuf: http://10.67.182.108 ===
  200  /index.html  [158 B]
  301  /development  → /development/     ← doorway

=== ffuf: http://10.67.182.108:8080 ===
  302  /manager       ← exists, wants auth
  302  /host-manager
>>>>>>> 6381c952b0e7f1e5f8034f0708c93b1f276d5138
```

## Script 2 — vuln probe (one input param at a time)

<<<<<<< HEAD
=======
Point it at **any URL that accepts user input** — `?param=value`, a search
box, anything from `<form>` / `<input name="...">` in view-source.

>>>>>>> 6381c952b0e7f1e5f8034f0708c93b1f276d5138
```bash
./web-vuln-tests.sh "http://<ip>/page?param=value"
```

<<<<<<< HEAD
Point it at **any URL that accepts user input** — `<form>`/`<input name>` from
view-source, a search box, an `?id=`. Stages:

| Stage | Class | How |
|---|---|---|
| 0 | param discovery | no `?param=`? arjun (if installed) hunts hidden GET/POST params for you |
| 1 | SQLi | quote/OR-1=1 payloads + error words + response-size diff |
| 2 | LFI | `/etc/passwd` variants — look for `root:x:` |
| 3 | SSTI | `{{7*7}}` (Jinja/Twig) **and** `${7*7}` (Spring/Velocity/JSP) → `49` |
| 4 | XSS | reflection marker, then **dalfox** automated execute-test when installed |
| 5 | CMDi | `;id;`, `$(id)`, `|id` — any `uid=`/`gid=` in the response |
| 6 | quick-hits | ffuf `quickhits.txt` sweep of the base page |

Rules:

- **Every `[+]` is a lead, not a verdict** — confirm with one curl by hand.
- **Clean pass = still a report line:** *"param X tested for
  SQLi/LFI/SSTI/XSS/CMDi — no anomalies."* Ruled-out classes score.
- Loot: `loot/vuln-tests-HHMM/` — `hits.txt` (always written), `manual-next-steps.txt`
  (exploit commands pre-filled), `arjun.txt`/`dalfox.txt` evidence when used.

Practice target offline: `testing/start-lab.sh` then point script 2 at
`http://127.0.0.1:8080/search?q=first` (SQLi+XSS) or `/file?path=readme.txt` (LFI).
Or `testing/run-example.sh` runs the whole demo in one go.

## Manual ladder (the deliberate part)

```bash
curl http://<ip>/<dir>/dev.txt               # notes often leak usernames/hints
enum4linux -a <ip> | grep -iE 'user|share'   # SMB → usernames
hydra -l <user> -P /usr/share/wordlists/rockyou.txt -t 10 -f <ip> ssh
```

Versioned services → exploit by version, not CVE guess:
=======
It mutates the value with: SQLi strings, `/etc/passwd` (LFI), `{{7*7}}`
(SSTI), and a reflection marker (XSS), then flags anomalies by
status/size/keywords.

Real example (local lab app):

```bash
./web-vuln-tests.sh "http://127.0.0.1:8080/search?q=first"
```

```
  [+] SQL-ish error surfaced on q'           ← append a ' → DB error
  [i] param 'q' is REFLECTED (XSS possible)  ← marker echoed back
```

### Rules

- **Every `[+]` is a lead, not a verdict.** Confirm with one `curl` by hand
  before spending time on it. (False positives happen — e.g. "no such file"
  once matched the SQL-error wordlist.)
- **Clean pass = still a report line.** *"Param q tested for
  SQLi/LFI/SSTI/XSS — no anomalies."* Ruled-out classes score.
- No `?param=value`? Not an error — the script says so. Find params via
  view-source, or:
  ```bash
  ffuf -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
       -u "http://<ip>/page?FUZZ=1" -fs <baseline-size>
  ```
- Loot: `loot/vuln-tests-HHMM/` — `hits.txt` (always written, even when
  empty) + `manual-next-steps.txt` (your exploit cmds, URL pre-filled).

## Manual ladder (the deliberate part)

Hand-run only, one technique at a time, note what worked for the report:

```bash
curl http://<ip>/<dir-found>/dev.txt        # note files often leak usernames/hints
enum4linux -a <ip> | grep -iE 'user|share'  # SMB/Samba → usernames
hydra -l <user> -P /usr/share/wordlists/rockyou.txt -t 10 -f <ip> ssh
```

Versioned services (from whatweb): exploit by version, not CVE guess:
>>>>>>> 6381c952b0e7f1e5f8034f0708c93b1f276d5138

```bash
searchsploit "Apache 2.4.41"
searchsploit "Tomcat 9.0.7"
<<<<<<< HEAD
curl -u admin:admin http://<ip>:8080/manager/html     # tomcat:tomcat next
```

AD when a Windows box appears:

```bash
bloodhound-python -u <u> -p '<p>' -d <domain> -dc <dc-ip> -ns <ip> -c All
netexec smb <ip> -u <u> -p '<p>' --shares
=======
curl -u admin:admin http://<ip>:8080/manager/html   # try tomcat:tomcat too
>>>>>>> 6381c952b0e7f1e5f8034f0708c93b1f276d5138
```

## Failure table

| Symptom | Cause → fix |
|---------|-------------|
<<<<<<< HEAD
| `target unreachable (000)` | box expired / VPN down / typo — check panel |
| live host, nmap silent | WSL NAT breaks SYN scans → `-sT` is baked into script 1 |
| ffuf `.md` unreadable | read `ffuf-summary.txt` instead |
| loot missing/empty | ran from the wrong directory |
| arjun/dalfox "not installed" | rerun `sudo ./install.sh`, or `apt install arjun dalfox` |
| RDP into the Kali VM fails | `sudo systemctl enable --now xrdp` (then connect :3389) |

## Report habit

For every interesting page/param/target: URL, test class, result, evidence path
(`loot/...`). Scripts make evidence; the report is graded on it.
=======
| script exits with `target unreachable (000)` | box expired / VPN down / IP wrong — check panel |
| live host but nmap shows nothing | WSL NAT breaks SYN scans → `-sT` is already baked in |
| ffuf `.md` is a wall of pipe-tables | read `ffuf-summary.txt` instead |
| loot folder missing/empty | you ran from the wrong directory |
| script silent about ffuf | `testing/ffuf_pretty.py` missing → put it back |

## Report habit

For every *interesting* page/param/target: write down the URL, test class,
result, and evidence path (`loot/...`). Collectors make evidence; the
report is graded on it.
>>>>>>> 6381c952b0e7f1e5f8034f0708c93b1f276d5138
