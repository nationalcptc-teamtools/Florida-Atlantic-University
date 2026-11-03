#!/usr/bin/env python3
"""ffuf_pretty.py <loot-dir> [--stdout-only]

Turn ffuf .md (and .csv) reports into a compact, human-readable summary file
(ffuf-summary.txt) in the same directory. Decodes the pipe-table ffuf emits,
groups rows, and flags find-worthy results vs. Apache noise.
"""
import glob
import os
import re
import sys

NOISE = {".hta", ".htaccess", ".htpasswd", "server-status", "server-info", "favicon.ico"}
HITS = {"200", "201", "401", "403"}
REDS = {"301", "302", "307"}


def split_pipe(line):
    parts = [p.strip() for p in line.split("|")]
    if parts and parts[0] == "":
        parts = parts[1:]
    if parts and parts[-1] == "":
        parts = parts[:-1]
    return parts


def parse_file(path):
    """Return (cmdline, rows). rows = [FUZZ,URL,Redirect,Position,Code,Len,...]"""
    cmdline, rows = None, []
    with open(path, encoding="utf-8", errors="replace") as fh:
        for ln in fh:
            ln = ln.rstrip("\n")
            m = re.match(r"\s*Command line : `(.*)`", ln)
            if m and cmdline is None:
                cmdline = m.group(1)
            s = ln.strip()
            if not s.startswith("|"):
                continue
            cells = split_pipe(s)
            if not cells:
                continue
            if cells[0] in ("FUZZ", ) or cells[0].startswith(":"):
                continue
            if len(cells) < 6:
                continue
            rows.append(cells)
    return cmdline, rows


def base_of(cmdline, rows):
    m = re.search(r"-u (\S+)/FUZZ", cmdline or "")
    if m:
        return m.group(1)
    if rows:
        b = re.match(r"(https?://[^/]+)", rows[0][1])
        if b:
            return b.group(1)
    return "?"


def path_of(url):
    m = re.match(r"https?://[^/]+(/.*)?$", url or "")
    return m.group(1) if (m and m.group(1)) else "/"


def summarize_md(path):
    cmdline, rows = parse_file(path)
    base = base_of(cmdline, rows)
    lines = [f"\n=== ffuf: {base} ==="]
    if not rows:
        lines.append("   (no results — either the wordlist found nothing, or the target was")
        lines.append("    unresponsive/down; probe manually with curl to tell which)")
        return lines

    hits, auths, noise = [], [], []
    for cells in rows:
        fuzz, url, redir = cells[0], cells[1], cells[2]
        code, clen = cells[4], cells[5]
        p = path_of(url)
        if fuzz.lower() in NOISE:
            noise.append(f"/{fuzz} ({code})")
            continue
        extra = f"  [{clen} B]" if clen.isdigit() else ""
        if code in HITS:
            hits.append(f"  {code}  {p}{extra}")
        elif code in REDS:
            tgt = f"  →  {path_of(redir)}" if redir else ""
            hits.append(f"  {code}  {p}{tgt}")
        else:
            auths.append(f"  {code}  {p}{extra}")

    if hits:
        lines.append("  -- real responses --")
        for h in sorted(hits, key=lambda x: x.split()[0]):
            lines.append(h)
    if auths:
        lines.append("  -- locked/forbidden (probe differently) --")
        for a in auths:
            lines.append(a)
    if noise:
        lines.append("  -- Apache defaults (noise, skip) --  " + ", ".join(sorted(noise)))
    return lines


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    d = sys.argv[1]
    stdout_only = "--stdout-only" in sys.argv
    files = []
    for pat in ("ffuf-*.md", "ffuf-*.csv"):
        files.extend(glob.glob(os.path.join(d, pat)))
    out = []
    for f in sorted(files):
        out.extend(summarize_md(f))
    text = "\n".join(out) + "\n"
    if not stdout_only:
        dest = os.path.join(d, "ffuf-summary.txt")
        with open(dest, "w", encoding="utf-8") as fh:
            fh.write(text)
    print(text, end="")
    if not stdout_only:
        print(f"[+] summary written to {os.path.join(d, 'ffuf-summary.txt')}")


if __name__ == "__main__":
    main()
