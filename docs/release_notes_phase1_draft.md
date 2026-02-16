# Avium Phase 1 Draft Release Notes

## Highlights

- Offline food safety search with badge-first list UI
- 0-result safety guardrail with emergency shortcut and request template mail
- Detail screen with condition chips (part x prep) and conservative fallback rules
- Emergency mode with rule-based risk output (Low/Medium/High)
- Beginner feeding guide and settings metadata (`dataVersion`, `reviewedAt`)
- Data copy/risk criteria revision (`1.2.2`):
  - `safe/caution` 경계를
    `즉시 증상 가능성/조리-전처리 리스크/가공-첨가물 편차` 중심으로 재정의
  - 단일 견과류 6종 및 두부를 `safe`로 조정
  - `foodMixedNuts`, `foodTempeh`, 옥살산 채소군은 `caution` 유지
  - `danger` 항목 `baseRisk=high` 규칙 유지

## Safety messaging

- Not a diagnosis or treatment app
- Emergency mode includes fixed recommendation to contact avian-capable care
- No home-treatment, medication, vomiting-induction guidance

## Known limits in Phase 1

- No server sync
- Data updates ship with app updates
- Dose/weight-based quantitative guidance excluded
