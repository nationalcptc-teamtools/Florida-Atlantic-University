# Windows Privesc & Loot Runbook (fill during CPTS Windows modules)

## Enumeration: winPEAS first, then manual checks

## Privesc matrix (fill as you learn — one command each)
- SeBackupPrivilege:    # robocopy /b, or the SeBackupPrivilegeCmdLets
- SeManageVolume:       # SeManageVolumeAbuse path
- Potato family:        # know which kernel → which potato (Lovely-Potato in UCI tools)
- BadSuccessor:         # OU control → dMSA (Invoke-BadSuccessor.ps1)
- Unattended/registry/GPP:
- Token impersonation (incognito):

## Loot commands (post-shell — every one is an English finding)
- Get-PSReadline path:  # (Get-PSReadlineOption).HistorySavePath
- Putty keys, RDCman, KeePass (recall UCI: RDCman Dump, KeePass)
- LSASS dump:           # mimikatz sekurlsa::logonpasswords (and the module route)
- SAM secrets:          # token::elevate → lsadump::sam / lsa_dump_sam
- DPAPI:                # sekurlsa::dpapi
- NTDS.dit:             # lsadump::dcsync or ntdsutil secret dump

## Restricted Admin / Pass The Hash
reg add DisableRestrictedAdmin (from UCI notes) then evil-winrm -H

## Free-vuln checklist (Windows)
no UAC, no host firewall, deprecated OS, LaZagne findings, VNC listening, over-privileged shares, clear creds in logs
