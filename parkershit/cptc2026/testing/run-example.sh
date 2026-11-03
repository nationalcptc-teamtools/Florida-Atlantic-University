#!/usr/bin/env bash
# demo: run web-vuln-tests.sh against the local lab app, from the RIGHT directory
cd '/mnt/c/Users/morta/OneDrive/Pictures/Documents/Default Project/cptc2026' || exit 1
pkill -f vuln-app.py 2>/dev/null; sleep 1
cd testing && nohup python3 vuln-app.py > app.log 2>&1 & disown
sleep 2
cd '/mnt/c/Users/morta/OneDrive/Pictures/Documents/Default Project/cptc2026' || exit 1
code=$(curl -sk --max-time 3 -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/)
echo "lab app status: $code"
echo
echo "################ RUN 1: /search?q=first ################"
bash ./web-vuln-tests.sh 'http://127.0.0.1:8080/search?q=first'
