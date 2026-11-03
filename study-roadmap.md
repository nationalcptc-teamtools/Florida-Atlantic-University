# Study roadmap — CPTC → CPTS → (later, if wanted) CRTO

Decision from 2026-10-26: the competition (Nov 7-8) is a pentest+report — CPTS is the right
prep. Red-team-operator content comes after, if the red team track still appeals then.

## Track overlap (Zero-Point "Red Team Operations / CRTO" vs CPTS)

Overlapping (~70% of technique content; CPTS covers):
- Credential access / kerberos attacks / token abuse (AD module)
- Lateral movement (WinRM, PsExec, logon types)
- Pivoting + SOCKS (dedicated module — strong overlap)
- Full Kerberos delegation family: unconstrained, constrained, RBCD, S4U2self
- MSSQL: linked servers, xp_cmdshell, escalation (Attacking Enterprise Networks)
- Domain dominance: DCSync, golden tickets, DPAPI, ADCS ESC1/2/3/4/8, DPERSIST, trusts
- Windows privesc (services, UAC, DLL search order)

CRTO-ONLY (no HTB module substitutes):
- Operating a real C2 (Cobalt Strike listeners, malleable C2, beacon behavior, session passing)
- Malware/implant fundamentals: .NET/PInvoke, process injection you write yourself
- Defense evasion tradecraft (ETW/AMSI, memory evasion, blending post-ex, artifact/dropper building)
- Initial access ops (payload/dropper/delivery chains, phishing infra)
- Red-team-style reporting (different genre from client pentest report)

## Where to learn the CRTO-only part (later)
1. Zero-Point Security's Red Team Operations course itself — labs include a licensed
   Cobalt Strike; the C2 ops are exactly what you pay for.
2. Free reps meanwhile: run Mythic or Sliver from Kali against your own GOAD lab for the
   "operator feel" without paying.
3. SpecterOps BloodHound University / adversary-simulation material for deep AD ops.

## Sequencer
1. NOW → Nov 7: CPTS path + CPTC prep (this repo) — done via Academy modules + machines.md tracker.
2. CPTC done → finish CPTS exam (capstone + report requirement rehearses CPTC muscle).
3. 2027: decide track. CRTO then, if red team ops still appeals. GOAD re-runs of AD modules
   (delegation, MSSQL, enterprise capstone) are the closest CRTO-flavored practice before paying.
