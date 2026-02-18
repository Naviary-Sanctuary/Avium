# Contributing to Avium

Avium에 기여해 주셔서 감사합니다.
이 문서는 이슈 등록부터 PR 머지까지의 기본 절차를 설명합니다.

## Before You Start

1. 기존 이슈/PR에 동일한 제안이 있는지 먼저 검색해 주세요.
2. 변경 범위가 크면 이슈를 먼저 열어 방향을 합의해 주세요.
3. 커뮤니티 규칙은 [Code of Conduct](CODE_OF_CONDUCT.md)를 따릅니다.

## Development Setup

```bash
flutter pub get
flutter analyze
flutter test
```

## Branch and Commit

- 기본 브랜치: `main`
- 권장 작업 브랜치 예시: `feat/<topic>`, `fix/<topic>`, `docs/<topic>`
- 하나의 PR에는 하나의 목적만 담아 주세요.
- 커밋 메시지는 변경 의도가 드러나게 작성해 주세요.

예시:

```text
feat(search): improve typo tolerance for food aliases
fix(emergency): guard null path in risk summary parser
docs(readme): add contribution and PR guide links
```

## Pull Request Process

1. 최신 `main`을 반영한 뒤 PR을 생성해 주세요.
2. PR 템플릿 항목(배경/변경사항/테스트/리스크)을 모두 작성해 주세요.
3. 관련 이슈가 있다면 `Closes #<number>`를 포함해 주세요.
4. UI 변경이 있으면 스크린샷 또는 화면 녹화 링크를 포함해 주세요.
5. 리뷰 코멘트에 대한 대응 내역을 명확히 남겨 주세요.

상세 기준은 [Pull Request Guide](docs/pull_request_guide.md)를
확인해 주세요.

## Required Checks

PR 전 최소 아래 항목은 로컬에서 실행해 주세요.

```bash
flutter analyze
flutter test
dart run tool/generate_search_tokens.dart --check
```

## Data Update Checklist

`assets/data/foods.json` 변경 시 아래를 함께 점검해 주세요.

1. `oneLinerKo`가 항목별 고유 문장인지 확인
2. `oneLinerKo`가 위험 원인을 직접 설명하는지 확인
3. `safetyLevel`/`baseRisk`/`reasonKo`/`riskNotesKo` 일관성 점검
4. 필요 시 `sources`, `safetyConditions` 일관성 점검
5. 출처 문서 업데이트:
   - `docs/food_data_sources.md`
   - `docs/source_link_audit.md`
6. 토큰 검증 재실행:
   - `dart run tool/generate_search_tokens.dart --check`

## License Boundary

- 코드 변경은 `LICENSE`(MIT) 정책을 따릅니다.
- 데이터/출처 매핑 변경은 `LICENSE_DATA.md` 정책을 따릅니다.

라이선스 경계가 불명확하면 PR 설명에 쟁점을 먼저 명시해 주세요.
