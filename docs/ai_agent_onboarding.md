# Avium 신규 AI Agent 온보딩 가이드

이 문서는 새로운 AI 에이전트가 Avium 저장소에 합류했을 때, 빠르게 맥락을 파악하고 안정적으로 작업하기 위한 기준 문서입니다.

## 1. 프로젝트 한 줄 요약

Avium은 앵무새 보호자가 오프라인에서 음식 안전도와 응급 대응 우선순위를 빠르게 확인할 수 있도록 만든 Flutter 앱입니다.

## 2. 우선순위 원칙

작업 우선순위는 아래 순서를 지킵니다.

1. 기능 동작 정확성
2. 사용자 오해를 줄이는 명확한 UI/UX
3. 유지보수성과 개발 생산성
4. 테스트 가능 구조와 회귀 방지

## 3. 아키텍처 요약

- Feature-first + layered 구조
- 핵심 디렉터리
  - `lib/core`: 공통 타입/테마/상태/공용 위젯
  - `lib/data`: 모델/파서/리포지토리/검색
  - `lib/features/*`: 화면과 도메인 로직
- 오프라인 데이터: `assets/data/foods.json`

상세 구조는 `docs/architecture.md`를 참고합니다.

## 4. 반드시 알아야 할 엔진

- 검색: `lib/data/search/search_service.dart`
- 조건 매칭: `lib/features/food_detail/domain/safety_condition_matcher.dart`
- 응급 위험도: `lib/features/emergency/domain/emergency_risk_engine.dart`

해당 로직 변경 시 관련 unit/widget test를 함께 갱신해야 합니다.

## 5. 개발/검증 기본 명령어

```bash
flutter pub get
flutter analyze
flutter test
```

데이터 토큰 검증:

```bash
dart run tool/generate_search_tokens.dart --check
```

## 6. 검색 성능/품질 점검 정책

아래는 CI가 아니라 로컬 전용입니다.

```bash
dart run tool/search_benchmark.dart --input assets/data/foods.json
dart run tool/search_quality_report.dart --input assets/data/foods.json --min-top1 0.80 --min-top3 0.95
```

이유: 실행 시간이 길어 PR 피드백 속도를 저하시킬 수 있기 때문입니다.

## 7. 데이터 수정 시 체크리스트

1. `assets/data/foods.json` 수정
2. `oneLinerKo`가 항목별 고유 문장인지 확인(동일 문장 반복 금지)
3. `oneLinerKo`가 위험 원인을 직접 설명하는지 확인(고정 금지형 문구 지양)
4. `safetyLevel`/`baseRisk`/`reasonKo`/`riskNotesKo` 일관성 점검
5. 필요 시 `sources`, `safetyConditions` 일관성 점검
6. 검색 토큰 재생성/검증
7. `docs/food_data_sources.md`와 `docs/source_link_audit.md` 업데이트
8. 테스트 및 분석 통과 확인

## 8. 안전도/리스크 판정 기준

- `safetyLevel`
  - `safe`: 먹어도 안전한 것. 과량 섭취로 비만/대사 부담이 생기면 `reasonKo`에 기록
  - `caution`: 양·빈도 누적 시 신체 부담 또는 증상 가능성이 있는 것
  - `danger`: 독성/질병 유발 등 신체 위험이 뚜렷한 것
- `baseRisk`
  - `low`: 먹어도 대체로 괜찮은 것
  - `medium`: 먹었을 때 증상이 있을 수 있는 것
  - `high`: 먹었을 때 치명적일 수 있는 것

## 9. 출처/링크 검증 정책

- 출처 URL은 실제 접근 가능한 링크를 우선 사용
- 자동 검증은 Playwright 기반으로 수행 가능
- 봇 차단(429/챌린지) 발생 시 문서에 제한 사항을 명시

## 10. UI/UX 기준

- 모바일에서 한눈에 이해 가능한 정보 구조를 우선
- "눌릴 것처럼 보이는데 안 눌리는" affordance 금지
- 위험/주의/안전은 색상 + 텍스트 + 아이콘으로 함께 전달
- 기술 용어(DB, 스키마 등)를 사용자 문구로 직접 노출하지 않음

## 11. 라이선스 경계

- 코드: `LICENSE` (MIT)
- 데이터 및 출처 매핑 문서: `LICENSE_DATA.md` (별도 정책)

데이터 재배포/상업적 이용 관련 변경은 라이선스 정책과 충돌하지 않는지 먼저 확인해야 합니다.

## 12. PR 작성 기준

PR 본문에는 최소 아래 내용을 포함합니다.

- 배경(Why)
- 변경사항(What)
- 테스트 결과(명령어 + 요약)
- 리스크/롤백 포인트
- 후속 작업(있다면)

작은 단위로 자주 올리고, 사용자 영향이 큰 UI 변경은 스크린샷 또는 동작 설명을 반드시 포함합니다.
