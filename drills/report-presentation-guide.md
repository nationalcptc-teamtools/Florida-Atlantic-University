# Report & Presentation Guide — mined from CPTC10 GLOBALS (12 finalist teams, A–L)
Build date 2026-11-03. Source: globalcptc/report_examples (CPTC10 report + presentation PDFs).

## The 12-deck pattern (what finalists actually did)

**Canonical flow (every deck):** Title → Team+roles → Agenda → Objectives → Scope →
Methodology → Executive Summary (counts + trend) → Key Findings (3–6) → Strengths →
Weaknesses → Recommendations (short/long-term) → Business impact → Conclusion → Q&A.
Typical length: **10–18 content slides** (winners were lean).

## Five presentation ideas worth stealing (identified across the corpus)

1. **Risk-trend triptych** (deck C): before/after/now severity charts splitting
   *remediated vs rediscovered vs new* — quantifies the client's progress story.
2. **Findings-to-themes rollup** (deck C): "24 findings → Access-control misconfigs (9),
   incomplete patching (3)…" — execs remember themes, not tickets.
3. **CWE bridge chart** (deck K): findings grouped by CWE ID → benchmarkable vs industry.
4. **One-slide critical attack path** (deck E): visual chain
   (cred exposure → vulnerable service → PII exfil) — the "how it becomes business impact" slide.
5. **Recommendation cards** (deck B): one card per rec with **effort + impact ratings** —
   instantly actionable prioritization for the client.

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
- Presentation: build the deck from the canonical flow above; steal ideas 1–5; keep ≤18 slides;
  every finding slide = one visual + one business sentence.
- Judge-facing framing for Butters Family Farm: expansion/investor due-diligence language,
  strengths section included, short/long-term remediation cards.

## Follow-up (backlog)

- ~~Mine report PDFs~~ **DONE 2026-11-03:** OCR'd finals-A (76pp) via local Tesseract pipeline —
  findings folded into `master-vuln-checklist.md` §G. Finals-C (79pp) OCR'd, text staged in
  Temp for a later pass; E–L reports remain unmined (OCR chain now exists on this box).
- 2r.is "how to CPTC" blog was unreachable tonight — retry and mine for tactics.
