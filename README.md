# 🍓 KDT 1조 스마트팜 (Ddalgi Farm) Mobile App

> **스마트 농장 관제 및 로봇 원격 제어, AI 비전 병충해 진단 통합 앱**
>
> Flutter 프레임워크 기반으로 구현된 스마트팜 모바일 애플리케이션으로, REST API 및 MQTT 실시간 프로토콜을 활용하여 농장 환경 데이터 모니터링, 자율주행 로봇 제어, AI 병충해 감지 및 수확 시기 예측 기능을 제공합니다.

---

## 📌 주요 기능 (Key Features)

1. **사용자 인증 및 세션 관리 (Authentication)**
    *   **로그인 & 회원가입**: 사용자 식별 및 자동 로그인 세션 관리
    *   **로그아웃**: 안전한 세션 종료 및 실시간 MQTT 연결 해제 (Settings 화면)
    *   **초기화 최적화**: 로그인 직후 모든 작물의 수확 시기를 선제적으로 예측하여 데이터 지연 해소

2. **AI 기반 농장 활동 캘린더 (Advanced Smart Calendar)**
    *   **직관적 레이아웃**: 날짜별 칸을 상(고온/고습 ↑), 중(메모), 하(저온/저습 ↓) 영역으로 분할 배치
    *   **AI 수확 예측**: 작물 생육 상태를 분석하여 수확 적기 자동 예측 및 우측 상단 아이콘 표시
    *   **상태 요약**: 질병(🟡), 온도(🔴), 습도(🔵), 수확(🟠) 발생 여부를 하단 색상 점으로 통합 표시
    *   **농장 메모**: 날짜별 최대 8자의 활동 메모 작성 (렌더링 충돌 방지 및 안전한 상태 업데이트 로직 적용)

3. **정밀 고정형 듀얼 Y축 실시간 차트 (Precision Monitoring)**
    *   **고정 레이아웃**: 가로 스크롤 시에도 습도(좌, %)와 온도(우, °C) 축이 화면 양 끝에 상시 고정
    *   **수직 정렬 최적화**: Y축 숫자와 차트 내부 가로 점선을 픽셀 단위로 일치시켜 판독 정확도 향상
    *   **상시 수치 표시**: 터치 없이도 모든 데이터 지점(Dot) 바로 위/아래에 실시간 수치를 텍스트로 노출
    *   **가동성 개선**: 불필요한 터치 피드백을 제거하고 데이터 밀도를 높여 한눈에 흐름 파악 가능

4. **로봇 원격 제어 및 실시간 경로 맵 (Robot Control)**
    *   **제어 패널**: 스냅 애니메이션 슬라이더를 통한 직관적인 순찰/정지 명령
    *   **U자 경로 맵**: 로봇의 현재 구역(Zone) 위치를 실시간 시각화
    *   **작동 이력**: 로봇의 과거 명령 수행 로그 및 성공 여부 조회

---

## 🛠 기술 스택 (Tech Stack)

| 구분 | 기술 스택 |
| :--- | :--- |
| **Framework** | Flutter (Dart, Material 3) |
| **State Management** | Provider (MultiProvider) |
| **Network & Protocols** | REST API (`http`), MQTT Client (`mqtt_client`) |
| **Data Visualization** | `fl_chart` (Custom Scoped Dual-Axis) |
| **Architecture** | Refactored MVVM (Modular Widgets & Typed Models) |

---

## 📂 프로젝트 구조 (Project Structure)

```text
lib/
├── core/
│   ├── app_constants.dart          # 🌟 전역 상수 (임계값, 스케일링, 타이머 등)
│   ├── api_config.dart             # 서버 및 MQTT 네트워크 설정
│   └── app_theme.dart              # 앱 전역 디자인 시스템 및 테마
├── models/
│   └── app_models.dart             # 🌟 타입 안정성을 위한 공유 데이터 모델 (RipenessData 등)
├── providers/
│   ├── auth_provider.dart          # 사용자 인증 관리
│   ├── crop_provider.dart          # 🌟 작물 상태 및 전역 수확 예측 로직 (선제적 계산 적용)
│   ├── environment_provider.dart   # 🌟 온습도 데이터 및 메모 관리 (Throttling 적용)
│   └── alert_provider.dart         # 질병 알림 및 로그 관리 (Memory Capping 적용)
├── controllers/
│   └── controller_fruit_dashboard.dart # 대시보드 전용 UI 컨트롤러
├── widgets/
│   ├── common/                     # 🌟 재사용 공통 위젯 (Scaffold, Button 등)
│   ├── calendar/                   # 🌟 캘린더 전용 고성능 하위 위젯
│   ├── robot/                      # 🌟 로봇 제어 모듈화 위젯
│   └── app_widgets.dart            # 통합 Export 관리자
├── screens/
│   ├── screen_calendar.dart        # 메인 캘린더 화면
│   ├── screen_fruit_dashboard.dart # 작물 상세 대시보드
│   └── ...                         # 기능별 독립 화면
└── main.dart                       # 앱 엔트리 포인트
```

---

## 📄 핵심 최적화 기술 문서 (Optimization & Stability)

### 1. 렌더링 안정성 (Anti-Crash Logic)
- **Safe State Updates**: 다이얼로그 종료와 상태 변경이 겹치지 않도록 `addPostFrameCallback`을 사용하여 렌더링 엔진 에러(`child._parent == this`) 방지
- **Pre-indexing**: 캘린더 빌드 시 리스트 탐색을 제거하고 $O(1)$ 복잡도의 전역 맵(Map) 조회를 구현하여 터치 타임아웃 해결

### 2. 성능 및 메모리 관리
- **UI Throttling**: 쏟아지는 MQTT 데이터에 대응하기 위해 0.5초 간격으로 리빌드를 제한하여 저사양 기기 지원
- **Memory Capping**: 실시간 로그 리스트를 최대 100개로 유지하여 장시간 구동 시 앱 무거워짐 방지
- **Explicit Disposal**: 모든 컨트롤러 및 타이머의 `dispose` 로직을 강화하여 메모리 누수 원천 차단

### 3. 데이터 시각화 정밀도
- **Dynamic Scaling**: 온도 데이터를 2배 스케일링하여 습도 데이터와 시각적 밸런스를 맞춤
- **Between Bars Filling**: 최고/최저치 사이의 영역만 투명하게 채워 하루의 환경 변화폭을 강조

---
© 2026 KDT 1조 스마트팜 (Ddalgi Farm). All rights reserved.
