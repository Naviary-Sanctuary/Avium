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
