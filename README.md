# Avium

Avium은 앵무새 보호자를 위한 오프라인 기반 급여/위험도 확인 Flutter 앱입니다.

## 핵심 목표

- 오프라인에서 빠른 음식 안전도 조회
- 실수 섭취 시 응급 대응 우선순위 확인
- 초보 보호자를 위한 기본 급여 가이드 제공
- 보수적이고 오해를 줄이는 안전 중심 UX

## 기술 스택

- Flutter (Dart)
- 라우팅: `go_router`
- 상태관리: Flutter 내장(`ChangeNotifier`, `ValueNotifier`)
- 데이터 저장소: 번들 JSON(`assets/data/foods.v1_2_0.json`)

## 프로젝트 구조

- `lib/core`: 공통 타입, 테마, 앱 상태, 공용 위젯
- `lib/data`: 모델, 리포지토리, 검색 로직
- `lib/features/search`: 검색/자동완성/0건 UX
- `lib/features/food_detail`: 상세/조건 매칭/근거 정보
- `lib/features/emergency`: 응급 위험도 계산/안내
- `lib/features/feeding_guide`: 기본 급여 가이드
- `lib/features/settings`: 앱 정보 및 데이터 메타
- `tool/`: 데이터 토큰/품질 점검 스크립트
- `docs/`: 아키텍처, 데이터 출처, 링크 점검 문서

## 로컬 실행

```bash
flutter pub get
flutter analyze
flutter test
```

## 데이터 토큰 생성

```bash
dart run tool/generate_search_tokens.dart --input assets/data/foods.v1_2_0.json
```

검증 모드:

```bash
dart run tool/generate_search_tokens.dart --check
```

## 검색 성능/품질 점검 (로컬 전용)

아래 두 검사는 시간이 오래 걸릴 수 있어 GitHub Actions CI에서는 실행하지 않고, 로컬에서만 실행합니다.

검색 벤치마크:

```bash
dart run tool/search_benchmark.dart --input assets/data/foods.v1_2_0.json
```

검색 품질 리포트:

```bash
dart run tool/search_quality_report.dart \
  --input assets/data/foods.v1_2_0.json \
  --min-top1 0.80 \
  --min-top3 0.95
```

## 문서

- 아키텍처: `docs/architecture.md`
- 에이전트 온보딩: `docs/ai_agent_onboarding.md`
- 데이터 출처: `docs/food_data_sources.md`
- 출처 링크 점검: `docs/source_link_audit.md`
- 릴리즈 노트 초안: `docs/release_notes_phase1_draft.md`

## 라이선스

- 코드: MIT (`LICENSE`)
- 데이터/출처 매핑 문서: 별도 라이선스 (`LICENSE_DATA.md`)
