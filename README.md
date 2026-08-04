# kdt — 딸기 농장 모니터링 및 제어 앱

Flutter로 만든 스마트팜 모니터링 앱입니다. 로그인 후 과일을 선택하면 실시간 환경 데이터(MQTT)와
AI 비전 병충해 알림을 확인하고, 순찰 로봇을 제어할 수 있습니다.

## 📖 처음이신가요?

**[docs/개발환경-가이드.md](docs/개발환경-가이드.md) 를 먼저 읽으세요.**

설치·실행·에러 해결이 전부 들어있습니다. 이 문서를 건너뛰고 시작하면
원인을 알 수 없는 에러로 몇 시간을 태우게 됩니다.

## 빠른 시작

```bash
# 1. 자바 확인 (17~25 사이여야 함)
flutter doctor -v | grep -A3 "Java binary"

# 2. 서버 주소 설정
cp .env.example .env        # 그리고 SERVER_IP 를 자기 환경에 맞게 수정

# 3. 실행 (안드로이드 에뮬레이터 또는 실제 폰)
flutter pub get
flutter run --dart-define-from-file=.env
```

VS Code에서는 **F5** 만 눌러도 됩니다.

## 구조

```
  [ kdt 앱 ]  ──HTTP  :12345──▶  [ 백엔드 서버 ]  ──▶  [ DB ]
              ──MQTT  :1883 ──▶  [ MQTT 브로커 ]
```

| 경로 | 설명 |
|---|---|
| `lib/main.dart` | 앱 진입점 |
| `lib/login_screen.dart` / `signup_screen.dart` | 로그인 / 회원가입 |
| `lib/screen_selection.dart` | 과일 선택 + 로봇 제어 슬라이더 |
| `lib/screen_fruit_dashboard.dart` | 실시간 차트 + MQTT 수신 |
| `lib/disease_alert_dialog.dart` | 병충해 감지 팝업 |
| `lib/api_config.dart` | 서버 주소 설정 (`.env` 에서 주입) |

## ⚠️ 서버는 이 저장소에 없습니다

이 저장소에는 **앱만** 들어 있습니다. REST API와 MQTT 브로커는 서버 담당자 PC에서 따로 돌아갑니다.
**서버가 꺼져 있으면 앱을 아무리 고쳐도 로그인은 실패합니다.**

로그인 시 `❌ 서버 연결 실패` 가 뜬다면 앱 문제가 아니라 서버 문제입니다.
자세한 판별법은 [가이드 6장](docs/개발환경-가이드.md)을 참고하세요.

## 요구 환경

| 항목 | 버전 |
|---|---|
| Flutter | 3.44.x (Dart 3.12.2) |
| JDK | **17 ~ 25** (26 이상은 빌드 실패) |
| Android SDK | API 36 |
