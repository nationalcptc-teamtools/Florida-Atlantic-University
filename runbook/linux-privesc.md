# Linux Privesc Runbook (fill during CPTS Linux privesc)

## Enumeration order (one-liner each, memorized — that is the point)
sudo -l                  # sudo misconfig FIRST
find SUID:               #
getcap -r /:             #
crontab -l + /etc/crontab:
ls ~/.ssh:               #
cat /proc/version + uname -a:      # kernel exploits check ("OverlayFS, DirtyCow etc." — verify vs. kernel version)
env:                     #
drives/mounts (/etc/fstab):
writable /etc/passwd:    # mkpasswd -m SHA-512, add root-uid line

## Hunt list (the UCI search loops — turn into your own .sh in setup/ and test it)
- .conf/.cnf/.py/.sh files with 'password' content
- /tmp, /var/tmp, /var/backups, /var/mail
- history files, SSH keys, PSReadLine equivalent

## Tools you will run
- linPEAS/linpeas.sh
- pspy (cron hunt)
- LinEnum, kernelpop

## Free-vulns from Linux boxes to report
old kernel, weak sudo configs, world-readable shadow backup, cron cleartext creds, capabilities on a shell
