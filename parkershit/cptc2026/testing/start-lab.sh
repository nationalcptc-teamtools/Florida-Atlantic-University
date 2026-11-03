#!/usr/bin/env bash
# start-lab.sh — spin up the local vulnerable lab app (127.0.0.1:8080)
# paths are relative to this file so it works from any clone location
cd "$(cd "$(dirname "$0")" && pwd)" || exit 1
pkill -f vuln-app.py 2>/dev/null
sleep 1
nohup python3 vuln-app.py > app.log 2>&1 &
disown
sleep 2
state=$(curl -sk --max-time 3 -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/)
echo "lab app status: $state"
[ "$state" = "000" ] && { echo "check app.log in the same folder for why it failed"; }
