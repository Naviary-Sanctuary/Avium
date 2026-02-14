# Avium

Avium is an offline-first Flutter app for parrot food safety lookup.

## Development

```bash
flutter pub get
flutter analyze
flutter test
```

## Scope

Phase 1 focuses on:

- Offline food safety lookup
- Emergency mode with rule-based urgency guidance
- Beginner feeding guide
- Accessibility-first UI and conservative safety messaging

## Data token generation

```bash
dart run tool/generate_search_tokens.dart --input assets/data/foods.v1_2_0.json
```

Check mode:

```bash
dart run tool/generate_search_tokens.dart --check
```

## Benchmark (Local only)

```bash
dart run tool/search_benchmark.dart --input assets/data/foods.v1_2_0.json
```

The benchmark exits with code `1` when average query time exceeds
`300ms`.
This check is intentionally run locally, not in GitHub Actions CI.

## Search quality report (Local only)

```bash
dart run tool/search_quality_report.dart --input assets/data/foods.v1_2_0.json
```

Optional thresholds:

```bash
dart run tool/search_quality_report.dart \
  --input assets/data/foods.v1_2_0.json \
  --min-top1 0.80 \
  --min-top3 0.95
```

This report is intentionally run locally, not in GitHub Actions CI.

## Docs

- Architecture: `docs/architecture.md`
- Draft release notes: `docs/release_notes_phase1_draft.md`

## License

- Code: MIT (`LICENSE`)
- Curated data and source-mapping docs: proprietary (`LICENSE_DATA.md`)
