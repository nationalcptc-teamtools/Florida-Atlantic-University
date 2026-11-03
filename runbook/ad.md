# Active Directory Runbook (fill during CPTS AD modules — this wins CPTC)

## The UCI chain, in order (run app-equivalent commands as you learn them):
1. Null session smb/ldap/rpc — enum4linux-ng -A, rpcclient -U "" -N, smbclient -L
2. nxc smb/ldap/mssql with default creds list  (admin:admin, administrator:administrator, guest:guest, abc:blank ...)
3. AS-REP Roast     GetNPUsers.py / nxc ldap --asreproast
4. Kerberoast       GetUserSPNs.py / nxc ldap --kerberoasting
5. BloodHound       bloodhound-python -c all --zip
6. Certipy find -vulnerable   (template ESCs)
7. Eight hundred privesc paths — BadSuccessor, GPP, smbghost, etc.
8. Shell → winpeas → Mimikatz (LSASS, SAM, LSA, DPAPI, DCSync)
9. Loot: descriptions, PSReadLine, KeePass, GPP, DPAPI, linked SQL servers (xp_cmdshell)

## Queue for the wordlists (build now, verify sizes):
usernames: (xato-10m, SeClists)

## Your netexec cheat rows (fill as you learn):
- asreproast:      #
- kerberoasting:   #
- password-spray:  # (rate-limit!)
- gmsa:            #
- dcsync:          #

## Off-box gotchas (Windows flag conventions — read before root.txt time)
- Old Windows boxes love **alternate data streams**: `dir /r` on the flag directory when the last step feels *too* easy.
- Flags aren't always named flag.txt — `history.txt` and friends show up on classic boxes.
- Kerberos wants FQDNs — put `<IP> full.hostname.domain` in `/etc/hosts` as soon as a domain name reveals itself.

## Free-vuln checklist (AD edition) — every one is a report entry:
anonymous grafana SMB, smb signing off, SMBv1, no UAC, deprecated OS, LDAP anon bind, password-not-required users, AS-REP users, GPP password, old MS Office descriptions holding creds
