---
title: Timing Drill — 4h half-speed CPTS box / 8h full CPTC simulation
---

## The drill (run every 1-2 weeks)

Phase 0 (15 min) — Read the brief. Write in-file: client, goal, scope, out-of-scope, tool restrictions.
Phase 1 (45 min) — Sweep + map: full TCP/UDP discovery. Nothing else. Produce a target table.
Phase 2 (2.5 h) — Per-host per-service runbook execution. One finding -> one note ->
   severities form (Critical/High/Med/Low/Info). No rabbit holes; at 30 min without
   progress, park it and move.
Phase 3 (45 min) — Consolidate. Outline the report, create network diagram (drawio/excalidraw), evidence screenshots named.
Phase 4 (rest) — Write findings using the UCI templates (severity-labeled).

## Close-out (15 min) — write two lines:
1. What broke / slowed us down → add to `runbook/…` so it never happens again.
2. Which free vuln did we miss that UCI's list would have caught.

## Scoring format (from UCI repo) — every finding has:
- Title (severity-prefixed, machine)
- Risk level
- Affected host(s)
- Summary + Business impact to the CLIENT (Butters Family Farm framing: expansion/investor due diligence)
- Evidence (screenshot + repro steps)
- Remediation (concrete, reference CIS benchmark where applicable)

## Inject-response drill (REBUILT from UF `report-generator\injects-bff\` — their structure, our scoring lens)

When an inject lands on competition day, you will have ~30-60 min. Structure beats prose.
The UF BFF template encodes a scoring-friendly skeleton — the markdown drill version:

1. **Bottom line first** (the "callout"): 1-3 sentences that ANSWER the ask outright —
   confirmed / completed / declined / here-is-what-we-found. Judges read this before anything else.
2. **Request as Understood:** restate the deliverable + deadline in one or two sentences.
   Cheapest possible insurance against answering the wrong question. Flag ambiguities here.
3. **Response body:** plain professional English, 2-4 paragraphs. No hedge you can't support;
   if unknown, say what it is AND how you'd find out.
4. **Actions Taken:** numbered, each including the **verification step** — judges score proof
   you confirmed outcomes, not that you assumed them. Anything incomplete: state why.
5. **Findings + risk table:** observation → business consequence (client framing!) in one
   sentence each, severity-labeled, evidence-referenced (Appendix refs).
6. **Assumptions/constraints:** "response reflects info as of [time] ET" + out-of-scope
   notes + decisions you need from the client. This section is free points on scoping credit.
7. **Evidence log appendix:** timestamped command/source table. Build it AS you work the
   engagement, not at response time.

The LaTeX templates live in `report-generator\injects-bff\` (compiles with xelatex → PDF);
the web findings log lives in `report-generator\`. Drill: pull a fake inject, time yourself
producing a 1-page response using this skeleton.
