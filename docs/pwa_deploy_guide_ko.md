# Avium PWA 배포 가이드 (한국어)

이 문서는 Avium을 앱스토어 없이 웹(PWA)로 배포하는 최소 절차를 정리합니다.

## 1. 로컬 확인

```bash
cd /Users/arthur/Desktop/project/naviary-santuary/Avium
flutter pub get
flutter run -d chrome
```

## 2. 프로덕션 빌드

```bash
flutter build web --release
```

빌드 결과물은 아래 디렉터리에 생성됩니다.

- `build/web/`

## 3. 정적 호스팅 배포

`build/web/`를 정적 파일 호스팅에 올리면 됩니다.

예시 호스팅:

- Cloudflare Pages
- Vercel
- Netlify
- GitHub Pages

### Vercel 빠른 배포(대시보드 업로드)

1. 로컬에서 빌드

```bash
flutter build web --release
```

2. Vercel 접속 후 새 프로젝트 생성
- https://vercel.com/new

3. `build/web` 폴더를 드래그 앤 드롭으로 업로드

4. 배포 완료 후 발급 URL을 모바일에서 접속

참고:
- Git 연동 배포 시에는 저장소 루트의 `vercel.json`이 적용됩니다.
- 이 저장소에는 SPA 라우팅 fallback 설정이 포함되어 있어 새로고침 시
  `index.html`로 리라이트됩니다.

### 공통 권장 설정

- HTTPS 강제
- 캐시 정책
  - `index.html`: 짧게(또는 no-cache)
  - `flutter_service_worker.js`, 정적 리소스: 해시 기반 장기 캐시 허용

## 4. 사용자 설치 방법(PWA)

### Android (Chrome)

- 사이트 접속 후 브라우저 메뉴에서 `홈 화면에 추가` 또는 `앱 설치`

### iOS (Safari)

- 공유 버튼 → `홈 화면에 추가`

## 5. 운영 시 주의사항

- iOS PWA는 네이티브 앱 대비 기능 제한이 있습니다.
- 푸시/백그라운드 동작은 플랫폼 제약을 받습니다.
- 정식 앱스토어 등록 대비 신뢰도(설치 경고/탐색성)는 낮을 수 있습니다.

## 6. 배포 전 체크리스트

1. `flutter analyze` 통과
2. `flutter test` 통과
3. `flutter build web --release` 성공
4. 실제 모바일 브라우저(Android/iOS)에서 설치 동작 점검
5. 핵심 플로우(검색/상세/응급/정보) 점검
