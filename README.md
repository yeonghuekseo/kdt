# 🍓 KDT 1조 스마트팜 (Ddalgi Farm) Mobile App

> **스마트 농장 관제 및 로봇 원격 제어, AI 비전 병충해 진단 통합 앱**
>
> Flutter 프레임워크 기반으로 구현된 스마트팜 모바일 애플리케이션으로, REST API 및 MQTT 실시간 프로토콜을 활용하여 농장 환경 데이터 모니터링, 자율주행 로봇 제어, AI 병충해 감지 알림 기능을 제공합니다.

---

## 📌 주요 기능 (Key Features)

1. **사용자 인증 (Authentication)**
    - **로그인 & 회원가입**: 사용자 식별 및 세션 유지 관리
    - **AuthProvider**: `ChangeNotifier`를 통한 전역 로그인 상태 및 사용자 정보 관리

2. **작물 선택 및 맞춤형 관제 (Fruit Selection & Dynamic Navigation)**
    - 다양한 작물(딸기 🍓, 사과 🍎, 포도 🍇, 복숭아 🍑)별 독립 대시보드 제공
    - 작물별 백엔드 과일 코드 매핑 및 맞춤형 데이터 필터링

3. **로봇 원격 제어 및 히스토리 (Robot Control & History)**
    - **제어 패널**: 정지/순찰/귀환 명령을 REST API를 통해 실시간 전송
    - **활동 이력**: 로봇의 작동 로그 및 이동 경로 히스토리 조회 기능

4. **실시간 환경 데이터 시각화 (Real-time Environmental Monitoring)**
    - **MQTT Protocol**: 전역 `MqttService`를 통한 실시간 온/습도 데이터 수신
    - **EnvironmentProvider**: 수신된 센서 데이터를 실시간으로 차트에 반영 (`fl_chart` 활용)

5. **AI 비전 병충해 감지 및 전역 알림 (AI Vision Disease Alert System)**
    - **싱글톤 MQTT 서비스**: 앱 전체에서 단 하나의 MQTT 연결 유지 및 브로드캐스트 스트림 제공
    - **즉각적 알림**: 어느 화면에서든 병충해 발생 시 커스텀 경고 다이얼로그(`DiseaseAlertDialog`) 출력
    - **AlertProvider**: 질병 발생 내역 히스토리 관리 및 S3 이미지 연동

6. **통합 디자인 시스템 (Design System & Theme)**
    - 세이지 올리브/로즈 브라운 기반 감성적 스마트팜 색상 팔레트 구축
    - `AppTheme`을 통한 일관된 UI/UX 제공

---

## 🛠 기술 스택 (Tech Stack)

| 구분 | 기술 스택 |
| :--- | :--- |
| **Framework** | Flutter (Dart, Material 3) |
| **State Management** | Provider (MultiProvider) |
| **Network & Protocols** | REST API (`http`), MQTT Client (`mqtt_client`) |
| **Data Visualization** | `fl_chart` |
| **Architecture** | MVVM (Models - Providers - Services - Screens) |

---

## 📂 프로젝트 구조 (Project Structure)

```text
lib/
├── core/
│   ├── api_config.dart             # 서버 IP, REST/MQTT 포트 및 토픽 중앙 관리
│   ├── app_theme.dart              # 공통 컬러 팔레트 및 ThemeData 정의
│   └── app_validators.dart         # 입력 폼 유효성 검사 로직
├── models/
│   └── app_models.dart             # 데이터 구조 (User, Robot, Crop 등) 정의
├── providers/
│   ├── auth_provider.dart          # 사용자 인증 상태 관리
│   ├── robot_provider.dart         # 로봇 상태 및 제어 로직
│   ├── alert_provider.dart         # 질병 알림 및 히스토리 관리
│   └── environment_provider.dart   # 실시간 센서 데이터 상태 관리
├── services/
│   └── service_mqtt.dart           # 싱글톤 기반 MQTT 통신 및 스트림 서비스
├── widgets/
│   ├── disease_alert_dialog.dart   # 전역 병충해 감지 팝업 모듈
│   └── app_widgets.dart            # 재사용 공통 위젯
├── screens/
│   ├── screen_login.dart           # 로그인 화면
│   ├── screen_signup.dart          # 회원가입 화면
│   ├── screen_selection.dart       # 작물 선택 및 메인 네비게이션
│   ├── screen_fruit_dashboard.dart # 실시간 모니터링 대시보드
│   ├── screen_robot_history.dart   # 로봇 활동 이력 조회
│   └── screen_settings.dart        # 앱 설정 및 사용자 정보 관리
└── main.dart                       # 앱 엔트리 포인트 (Provider 주입 및 초기화)
```

---

## 📄 파일별 상세 설명 (File Documentation)

### 1. `lib/services/service_mqtt.dart` (핵심)
- **역할**: 앱 전체의 MQTT 통신을 책임지는 **싱글톤(Singleton)** 서비스
- **주요 내용**: 
    - `StreamController.broadcast()`를 통해 수신된 메시지를 필요한 모든 Provider에게 전파
    - 자동 재연결 로직 및 전역 토픽(`robot/status`, `alert/disease`) 구독 관리

### 2. `lib/providers/` (상태 관리)
- **AuthProvider**: 로그인 성공 시 사용자 토큰 및 세션 정보 유지
- **RobotProvider**: 로봇의 현재 위치 및 상태 값을 UI에 바인딩
- **AlertProvider**: MQTT로부터 받은 질병 알림 데이터를 리스트화하여 관리

### 3. `lib/core/api_config.dart`
- **역할**: 백엔드 네트워크 설정 통합 관리
- **주요 내용**: 서버 IP, REST/MQTT 포트, 다이내믹 토픽 생성 메서드(`diseaseAlertTopic`) 제공

### 4. `lib/screens/` (주요 화면)
- **Login/Signup**: 사용자 인증 인터페이스
- **FruitDashboard**: 센서 데이터의 시각화 및 실시간 알림 로그 표시
- **RobotHistory**: 과거 로봇의 운행 기록을 리스트 형태로 조회

---

## 📡 API & MQTT 명세 (API & Protocol Specification)

### 1. REST API
| 기능 | Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **로그인** | `POST` | `/api/auth/login` | 사용자 ID/PW 검증 |
| **회원가입** | `POST` | `/api/auth/signup` | 신규 사용자 등록 |
| **로봇 제어** | `POST` | `/api/robot/command` | 로봇 명령 전송 (`start_patrol`, `stop` 등) |
| **히스토리 조회** | `GET` | `/api/history/robot` | 로봇 활동 이력 수신 |

### 2. MQTT Topics
| Topic | Direction | QoS | Description |
| :--- | :--- | :--- | :--- |
| `ddalgi/robot/status` | Sub | 0 | 로봇 실시간 상태/위치 데이터 수신 |
| `ddalgi/env/log/{fruit}` | Sub | 0 | 센서 실시간 환경 데이터 수신 |
| `ddalgi/alert/disease/{user_id}` | Sub | 0 | AI 비전 병충해 감지 및 이미지 URL 수신 |

---

## 🚀 시작하기 (Getting Started)

### 사전 요구 사항 (Prerequisites)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0.0 이상 권장)
- 백엔드 REST API & MQTT Broker 서버 가동 상태

### 실행 방법 (Run Application)
1. Repository 클론
```bash
git clone https://github.com/your-repo/ddalgi-farm-app.git
```
2. 패키지 설치
```bash
flutter pub get
```
3. 실행
```bash
flutter run
```

---
© 2026 KDT 1조 스마트팜 (Ddalgi Farm). All rights reserved.
