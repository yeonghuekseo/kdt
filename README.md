# 🍓 KDT 1조 스마트팜 (Ddalgi Farm) Mobile App

> **스마트 농장 관제 및 로봇 원격 제어, AI 비전 병충해 진단 통합 앱**
>
> Flutter 프레임워크 기반으로 구현된 스마트팜 모바일 애플리케이션으로, REST API 및 MQTT 실시간 프로토콜을 활용하여 농장 환경 데이터 모니터링, 자율주행 로봇 제어, AI 병충해 감지 알림 기능을 제공합니다.

---

## 📌 주요 기능 (Key Features)

1. **사용자 인증 (Authentication)**
    - **로그인 & 회원가입**: 사용자 식별(ID, PW, 이름, 전화번호, 이메일, 국가) 및 세션 유지 관리
    - 안전한 REST API 통신 기반 사용자 검증

2. **작물 선택 및 맞춤형 관제 (Fruit Selection & Dynamic Navigation)**
    - 다양한 작물(딸기 🍓, 사과 🍎, 포도 🍇, 복숭아 🍑)별 독립 대시보드 제공
    - 작물별 백엔드 과일 코드(`strawberry`, `apple`, `grape`, `peach`) 매핑

3. **로봇 원격 제어 패널 (Robot Control Panel)**
    - **스냅 인터랙티브 슬라이더**: 부드러운 애니메이션 스냅 동작(정지 ⏹️ / 순찰 동작 ▶️)을 통한 Intuitive UI
    - **원터치 귀환 명령**: 복귀(`return_home`) 명령 즉시 전송
    - 중복 신호 방지 로직 적용 및 백엔드 REST POST 명령 전달

4. **실시간 환경 데이터 시각화 (Real-time Environmental Chart)**
    - 백엔드 DB 연동 초기 차트 데이터 히스토리 조회 (REST GET)
    - **MQTT Protocol 연결**: `ddalgi/env/log/{fruit_code}` 토픽 구독을 통한 실시간 온/습도 수치 수신 및 차트 업데이트(`fl_chart` 활용)

5. **AI 비전 병충해 감지 및 알림 (AI Vision Disease Alert System)**
    - `ddalgi/alert/disease/{user_id}` MQTT 토픽 실시간 모니터링
    - 병충해 발생 시 즉시 **커스텀 경고 다이얼로그(Popup Dialog)** 출력
    - 발생 구역, 로봇 ID, 작물 구획, 생육 상태, S3 실시간 촬영 이미지 렌더링
    - 대시보드 내 진단 알림 히스토리 로그 관리

6. **통합 디자인 시스템 (Design System & Theme)**
    - 세이지 올리브/로즈 브라운 기반 감성적 스마트팜 색상 팔레트 구축
    - 재사용 가능한 커스텀 위젯 모듈화 (`PrimaryButton`, `CustomTextField`, `CustomTextButton`)

---

## 🛠 기술 스택 (Tech Stack)

| 구분 | 기술 스택 |
| :--- | :--- |
| **Framework** | Flutter (Dart, Material 3) |
| **Network & Protocols** | REST API (`http`), MQTT Client (`mqtt_client`) |
| **Data Visualization** | `fl_chart` |
| **UI Components** | Custom Material Widgets, Interactive Slider |
| **Data Format** | JSON |

---

## 📂 프로젝트 구조 (Project Structure)

```text
lib/
├── api_config.dart             # 서버 IP, REST/MQTT 포트 및 API 엔드포인트 중앙 관리
├── app_theme.dart              # 공통 컬러 팔레트(AppColors) 및 ThemeData 정의
├── app_widgets.dart            # 재사용 공통 위젯 (커스텀 버튼, 입력 필드 등)
├── disease_alert_dialog.dart   # 병충해 감지 팝업 모듈 (이미지 및 데이터 표시)
├── main.dart                   # 앱 엔트리 포인트 (App 시작 및 테마 적용)
├── login_screen.dart           # 사용자 로그인 화면
├── signup_screen.dart          # 신규 사용자 회원가입 화면
├── screen_selection.dart       # 작물 선택 카드 & 로봇 제어 슬라이더 화면
└── screen_fruit_dashboard.dart # 선택 작물 전용 대시보드 (MQTT 그래프 & AI 경고 로그)
```

---

## 📄 파일별 상세 설명 (File Documentation)

### 1. `lib/api_config.dart`
- **역할**: 백엔드 서버 네트워크 설정 통합 관리
- **주요 내용**:
    - `serverIp`: 백엔드 서버 IP (`192.168.0.6`)
    - `restPort` (12345) / `mqttPort` (1883)
    - REST API 엔드포인트 URL 모음 (`loginUrl`, `signupUrl`, `robotCommandUrl`, `dashboardLogsUrl`)

### 2. `lib/app_theme.dart`
- **역할**: 앱 전역 통합 디자인 테마 설정
- **주요 내용**:
    - `AppColors`: 배경(세이지 올리브), 메인(로즈 브라운), 버튼, 입력창 등 공통 색상 정의
    - `AppTheme`: `InputDecoration` 스타일 및 `ThemeData` 헬퍼 제공

### 3. `lib/app_widgets.dart`
- **역할**: 공통 UI 컴포넌트 모듈화
- **주요 위젯**:
    - `PrimaryButton`: 로딩 인디케이터 지원 메인 버튼
    - `CustomTextButton`: 텍스트 형태 링크 버튼
    - `CustomTextField`: 비밀번호 보이기/숨기기 토글 지원 입력 필드

### 4. `lib/disease_alert_dialog.dart`
- **역할**: AI 병충해 감지 경고 팝업 다이얼로그
- **주요 내용**:
    - `DiseaseAlertDialog.show()` static 메서드로 신속한 팝업 호출
    - 경고 메시지, 구역, 로봇 ID, 생육 상태 및 AWS S3 네트워크 이미지 출력

### 5. `lib/main.dart`
- **역할**: 앱 실행 진입점 (Entry Point)
- **주요 내용**:
    - `AppTheme.themeData` 일괄 적용
    - 최초 진입 화면으로 `LoginScreen` 지정

### 6. `lib/login_screen.dart`
- **역할**: 사용자 로그인 인증
- **주요 기능**:
    - ID/PW 입력 검증 및 REST POST (`/api/auth/login`) 통신
    - 로그인 성공 시 사용자 정보(`userId`, `userName`)를 지니고 `FruitSelectionScreen`으로 이동

### 7. `lib/signup_screen.dart`
- **역할**: 신규 회원가입
- **주요 기능**:
    - ID, PW, 이름, 전화번호, 이메일, 국가 필수 정보 입력
    - REST POST (`/api/auth/signup`) 통신 처리 및 완료 후 이전 화면 복귀

### 8. `lib/screen_selection.dart`
- **역할**: 작물 선택 및 로봇 원격 제어 인터페이스
- **주요 기능**:
    - 2열 그리드 기반 작물 선택 카드 (딸기, 사과, 포도, 복숭아)
    - 커스텀 텍스트 슬라이더(`TextSliderThumbShape`): 50ms 스냅 애니메이션 지원 (정지 ↔ 순찰 동작)
    - 로봇 귀환 버튼(`return_home`) 및 `/api/robot/command` 통신

### 9. `lib/screen_fruit_dashboard.dart`
- **역할**: 작물별 실시간 환경/AI 진단 대시보드
- **주요 기능**:
    - DB 히스토리 조회 (REST GET `/api/app/dashboard/logs?fruit={code}`)
    - **MQTT 실시간 데이터 처리**:
        - `ddalgi/env/log/{fruit_code}`: 실시간 그래프 점 추가 및 최대 20개 유지
        - `ddalgi/alert/disease/{user_id}`: AI 병충해 팝업 다이얼로그 호출 및 로그 리스트 추가

---

## 📡 API & MQTT 명세 (API & Protocol Specification)

### 1. REST API
| 기능 | Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **로그인** | `POST` | `/api/auth/login` | 사용자 ID/PW 검증 |
| **회원가입** | `POST` | `/api/auth/signup` | 신규 사용자 등록 |
| **로봇 제어** | `POST` | `/api/robot/command` | 로봇 명령 전송 (`start_patrol`, `stop`, `return_home`) |
| **대시보드 로그**| `GET` | `/api/app/dashboard/logs?fruit={code}` | 초기 대시보드 차트 데이터 수신 |

### 2. MQTT Topics
| Topic | Direction | QoS | Description |
| :--- | :--- | :--- | :--- |
| `ddalgi/env/log/{fruit_code}` | Sub | At most once (0) | 센서 실시간 환경 데이터 (온도, 수치 등) 수신 |
| `ddalgi/alert/disease/{user_id}` | Sub | At most once (0) | AI 비전 병충해 감지 이벤트 및 이미지 URL 수신 |

---

## 🚀 시작하기 (Getting Started)

### 사전 요구 사항 (Prerequisites)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0.0 이상 권장)
- Dart SDK
- 백엔드 REST API & MQTT Broker 서버 실행

### 패키지 의존성 (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  mqtt_client: ^10.0.0
  fl_chart: ^0.68.0
```

### 실행 방법 (Run Application)
1. Repository 클론
```bash
git clone https://github.com/your-repo/ddalgi-farm-app.git
cd ddalgi-farm-app
```

2. 네트워크 설정 (`lib/api_config.dart`)
```dart
static const String serverIp = 'YOUR_SERVER_IP'; // 실제 서버 IP로 변경
```

3. 패키지 설치 및 실행
```bash
flutter pub get
flutter run
```

---

## 🎨 화면 미리보기 구성 요약 (UI Overview)

- **로그인 / 회원가입**: 깔끔한 샌드/올리브 톤 커스텀 입력 필드 및 버튼
- **과일 선택 & 로봇 제어**: 원터치 귀환 및 슬라이딩 드래그 패널
- **대시보드**: 커브 라인 실시간 차트 및 AI 비전 이상 감지 카드 리스트

---
© 2026 KDT 1조 스마트팜 (Ddalgi Farm). All rights reserved.
