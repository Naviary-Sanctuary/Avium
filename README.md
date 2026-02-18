# Avium

Avium은 앵무새 보호자가 음식 안전도와 응급 대응 우선순위를
오프라인에서 빠르게 확인할 수 있도록 만든 Flutter 앱입니다.

## Table of Contents

- [Why Avium](#why-avium)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Data and License Boundaries](#data-and-license-boundaries)
- [Contributing](#contributing)
- [Community Health Files](#community-health-files)
- [Documentation](#documentation)
- [License](#license)

## Why Avium

- 네트워크가 불안정한 상황에서도 동작하는 오프라인 안전도 조회
- 섭취 사고 시 응급 우선순위를 빠르게 판단하는 가이드
- 초보 보호자도 이해하기 쉬운 보수적이고 명확한 UX
- 데이터 근거와 링크 점검 정책이 분리된 유지보수 가능한 구조

## Key Features

- 음식 검색, 자동완성, 0건 대응 UX
- 음식 상세 안전도/주의조건/근거 정보
- 응급 위험도 계산 엔진
- 기본 급여 가이드
- 웹(PWA) 배포 지원

인앱브라우저(카카오톡, Instagram, Facebook, LINE, NAVER, Daum,
TikTok, WeChat, LinkedIn, X, Reddit, Pinterest, Snapchat) 첫 진입 시
렌더링 실패가 감지되면 외부 브라우저(Chrome/Safari) 복구 UI를
노출합니다.

## Tech Stack

- Flutter (Dart)
- Routing: `go_router`
- State: `ChangeNotifier`, `ValueNotifier`
- Data: `assets/data/foods.json` (bundled JSON)

## Getting Started

### Prerequisites

- Flutter stable SDK
- Dart SDK (Flutter 포함)

### Install and Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

### Build for Web

```bash
flutter build web --release
```

### Validate Search Tokens

```bash
dart run tool/generate_search_tokens.dart --check
```

## Project Structure

- `lib/core`: 공통 타입, 테마, 앱 상태, 공용 위젯
- `lib/data`: 모델, 리포지토리, 검색 로직
- `lib/features/search`: 검색/자동완성/0건 UX
- `lib/features/food_detail`: 상세/조건 매칭/근거 정보
- `lib/features/emergency`: 응급 위험도 계산/안내
- `lib/features/feeding_guide`: 기본 급여 가이드
- `lib/features/settings`: 앱 정보 및 데이터 메타
- `tool/`: 데이터 토큰/품질 점검 스크립트
- `docs/`: 아키텍처/데이터/배포/협업 문서

## Data and License Boundaries

- 코드 라이선스: [MIT](LICENSE)
- 데이터/출처 매핑 문서 라이선스: [LICENSE_DATA.md](LICENSE_DATA.md)
- 데이터를 변경할 때는 출처 문서(`docs/food_data_sources.md`,
  `docs/source_link_audit.md`)를 함께 갱신해야 합니다.

## Contributing

기여 전 아래 문서를 먼저 확인해 주세요.

- [Contributing Guide](CONTRIBUTING.md)
- [Pull Request Guide](docs/pull_request_guide.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## Community Health Files

- 이슈 템플릿: `.github/ISSUE_TEMPLATE/`
- PR 템플릿: `.github/pull_request_template.md`
- CI: `.github/workflows/ci.yaml`

## Documentation

- [Architecture](docs/architecture.md)
- [AI Agent Onboarding](docs/ai_agent_onboarding.md)
- [PWA Deploy Guide (KO)](docs/pwa_deploy_guide_ko.md)
- [Food Data Sources](docs/food_data_sources.md)
- [Source Link Audit](docs/source_link_audit.md)
- [Release Notes Draft](docs/release_notes_phase1_draft.md)

## License

코드는 MIT 라이선스를 따르며, 데이터 관련 문서는 별도 라이선스 정책을
따릅니다. 상세 내용은 `LICENSE`, `LICENSE_DATA.md`를 참고해 주세요.
