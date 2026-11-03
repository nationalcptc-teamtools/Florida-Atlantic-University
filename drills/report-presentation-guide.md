# Report & Presentation Guide — mined from CPTC10 GLOBALS (12 finalist teams, A–L)
Build date 2026-11-03. Source: globalcptc/report_examples (CPTC10 report + presentation PDFs).

## The 12-deck pattern (what finalists actually did)

**Canonical flow (every deck):** Title → Team+roles → Agenda → Objectives → Scope →
Methodology → Executive Summary (counts + trend) → Key Findings (3–6) → Strengths →
Weaknesses → Recommendations (short/long-term) → Business impact → Conclusion → Q&A.
Typical length: **10–18 content slides** (winners were lean).

## Six presentation/report ideas worth stealing

1. **Risk-trend triptych** (deck C): before/after/now severity charts splitting
   *remediated vs rediscovered vs new* — quantifies the client's progress story.
2. **Findings-to-themes rollup** (deck C): "24 findings → Access-control misconfigs (9),
   incomplete patching (3)…" — execs remember themes, not tickets.
3. **CWE bridge chart** (deck K): findings grouped by CWE ID → benchmarkable vs industry.
4. **One-slide critical attack path** (deck E): visual chain
   (cred exposure → vulnerable service → PII exfil) — the "how it becomes business impact" slide.
5. **Recommendation cards** (deck B): one card per rec with **effort + impact ratings** —
   instantly actionable prioritization for the client.
6. **Kill-chain diagram** (2r.is/CCSF blog): a graphical flow chart summarizing the whole
   pentest — how techniques jumped box to box. No other team had it; judges called it out.
   Build it DURING the comp from the session logs (draw.io/excalidraw), not after.

## Presentation timing law (from the CCSF blog — they LOST POINTS not knowing this)

- **Everyone on the team must speak.** Non-negotiable scoring requirement.
- Fit the talk into **~7–8 minutes**, leaving **20–30% of the slot for questions** —
  the board needs room for at least two questions. Plan the clock, don't discover it at debrief.
- Don't get overly technical; tie findings into the bigger exec picture: overall security
  posture + how to move forward + what this industry specifically worries about.

## Competition-conduct laws (blog, points-lost provenance)

- **Easier to ask permission than forgiveness:** before anything risky (lockouts, password
  resets, anything near scope edges) → message the company team first. Points off otherwise.
- **Broke something? Own up immediately.** If asked, never guess-deny; say you need a moment
  to check with the team. Never lie — integrity is scored.
- **Critical findings get disclosed to the client DURING the comp**, not saved for the report.
- **Injects:** designate two people to own them; the rest keep hunting. Research → synthesize
  → submit where the inject says, by the deadline, every time.
- Screenshots: clear and uncluttered; **a PoC showing RCE beats an nmap line saying it's
  possible.** Repro steps must let the client's engineer replicate the finding unaided.
- Notes during the comp should be **report-ready drops**, not raw terminal paste.

## Industry-regulation research (do this BEFORE competition day)

The client industry drives the business-impact language. CCSF prepped NERC CIP for a power
company; for **Butters Family Farm** the team should pre-research: food/ag compliance
(FSMA-style food-safety expectations), agricultural data privacy, investor due-diligence
standards — plus real fine/penalty examples to cite in impact paragraphs. One prep session,
massive report leverage.

## Tool gaps the blog surfaced (added to installer 2026-11-03)

nikto, wpscan, davtest, autorecon, cewl, metasploit, wireshark, rpcclient (via samba);
offline-RE trio for custom competition software: dotpeek (.NET decompile — the blog's SCADA
GUI story), ghidra, strings/file. Also: CTFNote-style shared notepad = our Planka/report-generator stack.

## Follow-up (backlog)

- ~~Mine report PDFs~~ **DONE 2026-11-03:** OCR'd finals-A (76pp) via local Tesseract pipeline —
  findings folded into `master-vuln-checklist.md` §G. Finals-C (79pp) OCR'd, text staged in
  Temp for a later pass; E–L reports remain unmined (OCR chain now exists on this box).
- ~~2r.is blog~~ **MINED 2026-11-03** (user pasted full text; site was down): conduct laws,
  timing law, kill-chain diagram, regulation prep, tool gaps — all folded above.

## Weaknesses the weaker decks showed (avoid all)

- Text-dump findings with **no screenshots** and no quantified impact
- Template residue (stock-template credits slides, dated placeholders, typos like "TECHINICAL")
- Raw CVSS component dumps without executive translation; vague conclusions ("room for improvement")
- 35–42-slide decks with repeated thin sections and empty methodology slides
- Identical scope wording copy-pasted with no insight derived from it

## Report-side laws (consistent across the corpus)

- Findings format: severity-labeled, one finding per section, evidence screenshot + command
  + affected hosts, business-impact paragraph in client language, concrete remediation.
- Executive summary states counts by severity and the trend story up front.
- Strengths section exists (judges reward balance, not fear-mongering).
- Recommendations split short/long-term with effort ratings.
- Appendices: evidence log, tools used, methodology detail (PTES/CVSS references seen).

## Our apply-plan

- Report: use `report-generator/` (UF) — its finding fields (details/confirmation/impact/
  mitigation/references) match the corpus pattern exactly; prewrites cover most recurring findings.
- Presentation: build the deck from the canonical flow above; steal ideas 1–6; keep ≤18 slides;
  every finding slide = one visual + one business sentence. **Rehearse the 7–8 min clock and
  everyone-speaks rule in practice sessions.**
- Judge-facing framing for Butters Family Farm: expansion/investor due-diligence language,
  strengths section included, short/long-term remediation cards, industry-regulation research
  session completed beforehand.
