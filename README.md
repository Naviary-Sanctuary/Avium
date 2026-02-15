# Avium

Avium은 앵무새를 키우는 분들이 일상에서 급여 안전도와 응급 대응
우선순위를 빠르게 확인할 수 있는 오프라인 Flutter 앱입니다.

## 핵심 목표

- 집에서 바로 확인하는 오프라인 음식 안전도 조회
- 뜻밖의 섭취 상황에서 먼저 확인할 응급 대응 가이드
- 처음 키우는 분도 따라오기 쉬운 기본 급여 가이드 제공
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

웹(PWA) 로컬 실행:

```bash
flutter run -d chrome
```

웹(PWA) 프로덕션 빌드:

```bash
flutter build web --release
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
- PWA 배포 가이드: `docs/pwa_deploy_guide_ko.md`
- 데이터 출처: `docs/food_data_sources.md`
- 출처 링크 점검: `docs/source_link_audit.md`
- 릴리즈 노트 초안: `docs/release_notes_phase1_draft.md`

## 라이선스

- 코드: MIT (`LICENSE`)
- 데이터/출처 매핑 문서: 별도 라이선스 (`LICENSE_DATA.md`)

## 배포 서명 보안

- 실제 비밀값은 `android/key.properties`에 두고 Git에는 커밋하지 않습니다.
- 샘플은 `android/key.properties.example`을 사용하세요.
- 릴리즈 빌드(`appbundle/apk release`) 시 서명 설정이 없으면 빌드가 실패하도록 구성되어 있습니다.
