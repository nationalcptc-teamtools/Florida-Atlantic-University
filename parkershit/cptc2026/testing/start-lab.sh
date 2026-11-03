#!/usr/bin/env bash
cd '/mnt/c/Users/morta/OneDrive/Pictures/Documents/Default Project/cptc2026/testing'
pkill -f vuln-app.py 2>/dev/null
sleep 1
nohup python3 vuln-app.py > app.log 2>&1 &
disown
sleep 2
state=$(curl -sk --max-time 3 -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/)
echo "lab app status: $state"
