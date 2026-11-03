im upset
---

# Web Vuln Runbook — CPTC

**Doctrine: collect with scripts, exploit by hand.**
Scripts find attack surface. Exploitation (hydra, sqlmap, privesc) is a
deliberate step **after** reading the results — never fired blind.

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

## Script 1 — recon sweep (every target, first)

```bash
echo y | ./web-recon.sh <ip>
```

The `echo y |` confirms the target is in scope at the script's gate —
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
```

## Script 2 — vuln probe (one input param at a time)

Point it at **any URL that accepts user input** — `?param=value`, a search
box, anything from `<form>` / `<input name="...">` in view-source.

```bash
./web-vuln-tests.sh "http://<ip>/page?param=value"
```

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

```bash
searchsploit "Apache 2.4.41"
searchsploit "Tomcat 9.0.7"
curl -u admin:admin http://<ip>:8080/manager/html   # try tomcat:tomcat too
```

## Failure table

| Symptom | Cause → fix |
|---------|-------------|
| script exits with `target unreachable (000)` | box expired / VPN down / IP wrong — check panel |
| live host but nmap shows nothing | WSL NAT breaks SYN scans → `-sT` is already baked in |
| ffuf `.md` is a wall of pipe-tables | read `ffuf-summary.txt` instead |
| loot folder missing/empty | you ran from the wrong directory |
| script silent about ffuf | `testing/ffuf_pretty.py` missing → put it back |

## Report habit

For every *interesting* page/param/target: write down the URL, test class,
result, and evidence path (`loot/...`). Collectors make evidence; the
report is graded on it.
