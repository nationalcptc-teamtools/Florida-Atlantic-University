# Web Runbook (fill during CPTS Web modules)

Rule: run the UCI "Website Checklist" order verbatim on EVERY web target, in this order:
1. Free vulns sweep (anti-CSRF, cookies, HTTP vs HTTPS, self-signed cert, no MFA, no WAF, user enum via failed logins)
2. Directory enumeration
3. Subdomain/vhost enumeration
4. Inspect element + scripts for hints
5. Cookies / local storage
6. Parameter fuzz → then for each input: SQLi → XSS → XXE → Command Injection → SSTI → SSRF → LFI → File Upload

## Your ffuf setup
```
# your actual vhost command:
# your actual dir/fuzz command:
```

## Tooling dials (fill in YOUR verified flags)
- sqlmap: — your verified boolean-style invocation with -r req.txt
- XSS blind: your listener + payload templates saved as snippets
- XXE: your DTD template
- SSTI: your engine-detection payload (memorize ${{<%[%'"}}%\.)
- SSRF: your ffuf POST template + Gopher for POST
- JWT/cookies:

## Free-vuln candidates to report from ANY web finding
(user enum, weak cookies, SQLi confirm, custom-header cleverness, etc.)
