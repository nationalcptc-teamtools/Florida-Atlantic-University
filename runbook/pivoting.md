# Pivoting Runbook (fill during CPTS Pivoting/HTB Academy)

Scenario-first — know WHICH tool solves WHICH scenario (this is the scored decision):

| Scenario | First choice | Fallback |
|---|---|---|
| Port pinned to one internal service | ssh -L | meterpreter portfwd |
| Full internal subnet access over SSH | sshuttle | ssh -D + proxychains |
| Windows pivot host, GNU/Linux inner | chisel socks5 | plink -D + proxychains |
| Reverse tunnel (firewall blocks inbound) | chisel --reverse + R:socks | RPivot |
| DNS-only egress | dnscat2 | iptunnel via ICMP (ptunnel-ng) |
| Via RDP into target network | SocksOverRDP + Proxifier | — |
| Modern/quick, both directions | ligolo-ng | chisel |

## Fill in your verified commands (from the Academy module, YOUR hands)
ssh tunnels:      #
meterpreter:      #
proxychains conf: #
chisel:           #
ligolo:           #

## Timesaver notes
- Always set proxychains' port BEFORE you start the tunnel (kill the default 9050 tor line).
- Ligolang kills proxychains for everything, prefer it when HTTP(s) only.
