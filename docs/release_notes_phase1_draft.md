# Avium Phase 1 Draft Release Notes

## Highlights

- Offline food safety search with badge-first list UI
- 0-result safety guardrail with emergency shortcut and request template mail
- Detail screen with condition chips (part x prep) and conservative fallback rules
- Emergency mode with rule-based risk output (Low/Medium/High)
- Beginner feeding guide and settings metadata (`dataVersion`, `reviewedAt`)
- Data copy/risk criteria revision (`1.2.1`): all `oneLinerKo` rewritten,
  `danger` base risk unified to `high`, and processed-food reclassification
  applied for bread/jam (`safe -> caution`)

## Safety messaging

- Not a diagnosis or treatment app
- Emergency mode includes fixed recommendation to contact avian-capable care
- No home-treatment, medication, vomiting-induction guidance

## Known limits in Phase 1

- No server sync
- Data updates ship with app updates
- Dose/weight-based quantitative guidance excluded
