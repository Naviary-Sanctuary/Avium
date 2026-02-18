# Pull Request Guide

이 문서는 Avium 저장소의 PR 품질 기준과 리뷰 흐름을 정의합니다.
목표는 회귀를 줄이고, 변경 의도를 명확히 전달하는 것입니다.

## 1. PR Scope

- PR 하나는 하나의 문제를 해결해야 합니다.
- 리팩터링과 기능 추가가 함께 필요하면 커밋 또는 PR을 분리해 주세요.
- 대규모 변경은 먼저 이슈로 설계를 합의한 뒤 구현해 주세요.

## 2. PR Title

권장 형식:

```text
type(scope): short summary
```

예시:

- `feat(search): add synonym normalization for korean aliases`
- `fix(detail): prevent null condition rendering crash`
- `docs(readme): add open source community health sections`

## 3. Required PR Description

PR 본문에는 최소 아래 내용을 포함해야 합니다.

- 배경(Why): 왜 이 변경이 필요한지
- 변경사항(What): 무엇을 바꿨는지
- 테스트(Validation): 어떤 명령으로 검증했는지
- 리스크(Risk): 장애 가능 지점과 영향 범위
- 롤백(Rollback): 되돌릴 때의 기준과 방법

## 4. Quality Gate

PR 제출 전 로컬에서 아래 명령을 실행해 주세요.

```bash
flutter analyze
flutter test
dart run tool/generate_search_tokens.dart --check
```

데이터 품질 점검이 필요한 경우:

```bash
dart run tool/search_benchmark.dart --input assets/data/foods.json
dart run tool/search_quality_report.dart \
  --input assets/data/foods.json \
  --min-top1 0.80 \
  --min-top3 0.95
```

## 5. Data Change Rules

`assets/data/foods.json` 수정 시 다음을 함께 확인해 주세요.

- `oneLinerKo` 중복 문장 금지
- 위험 원인 중심 서술 유지
- `safetyLevel`/`baseRisk`/설명 필드 간 정합성 유지
- `docs/food_data_sources.md` 업데이트
- `docs/source_link_audit.md` 업데이트

## 6. UI Change Rules

- 사용자 영향이 있는 UI 변경은 스크린샷 또는 동작 영상 필수
- "눌릴 것처럼 보이는데 안 눌리는" UX를 금지
- 위험도 전달은 색상 + 텍스트 + 아이콘을 함께 사용

## 7. Review and Merge

- 리뷰 코멘트에 대해 수정 또는 근거를 명확히 남겨 주세요.
- CI 실패 시 머지하지 않습니다.
- 충돌 해결 후에는 핵심 검증 명령을 다시 실행해 주세요.

## 8. Fast Checklist

- [ ] PR 범위가 단일 목적이다.
- [ ] PR 템플릿을 모두 작성했다.
- [ ] 필수 검증 명령을 실행했다.
- [ ] 데이터 변경 시 출처 문서를 업데이트했다.
- [ ] UI 변경 시 스크린샷/영상을 첨부했다.
