# Avium Phase 1 Architecture

## Layers

- `lib/core`: shared theme, state scope, reusable widgets, enums
- `lib/data`: JSON schema models, repository, search/index logic
- `lib/features/search`: search home, 0-result safety UX
- `lib/features/food_detail`: first-view summary, condition matching
- `lib/features/emergency`: rule-based urgency guidance
- `lib/features/feeding_guide`: beginner feeding baseline
- `lib/features/settings`: data metadata visibility

## Data flow

1. `AppState.initialize()` loads bundled JSON with `AssetFoodRepository`.
2. Search input updates query in `AppState`.
3. `SearchService` returns ranked result list.
4. Detail and emergency screens read selected item via `AppState.getById`.

## Rule engines

- Safety condition: `SafetyConditionMatcher`
- Emergency risk: `EmergencyRiskEngine`

Both engines are covered by unit tests for deterministic regression checks.
