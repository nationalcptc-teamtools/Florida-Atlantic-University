#!/usr/bin/env bash
# run-example.sh — demo loop: start the lab app, run script 2 against it
# paths are relative to this file (works in any clone)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
pkill -f vuln-app.py 2>/dev/null; sleep 1
cd "$(dirname "$0")" && nohup python3 vuln-app.py > app.log 2>&1 & disown
sleep 2
cd "$ROOT" || exit 1
code=$(curl -sk --max-time 3 -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/)
echo "lab app status: $code"
echo
echo "################ RUN 1: /search?q=first ################"
bash ./web-vuln-tests.sh 'http://127.0.0.1:8080/search?q=first'
