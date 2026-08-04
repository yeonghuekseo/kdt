// lib/api_config.dart
//
// 서버 주소는 사람마다/환경마다 다르므로 코드에 직접 적지 않는다.
// 프로젝트 루트의 .env 파일에서 읽어오며, .env 는 git에 올리지 않는다.
//
// 실행 방법:
//   flutter run --dart-define-from-file=.env
//
// .env 가 없거나 값이 비어 있으면 아래 defaultValue 가 사용된다.
// 자세한 내용은 docs/개발환경-가이드.md 참고.

class ApiConfig {
  // 1. 서버 IP 및 포트 설정 (.env 에서 주입)
  static const String serverIp = String.fromEnvironment(
    'SERVER_IP',
    defaultValue: '192.168.0.6', // 백엔드 서버 IP
  );
  static const int restPort = int.fromEnvironment(
    'REST_PORT',
    defaultValue: 12345, // HTTP REST API 포트
  );
  static const int mqttPort = int.fromEnvironment(
    'MQTT_PORT',
    defaultValue: 1883, // MQTT 포트
  );

  // 2. Base URL 정의
  static const String baseUrl = 'http://$serverIp:$restPort';

  // 3. API 엔드포인트 URL 모음
  static const String loginUrl = '$baseUrl/api/auth/login';
  static const String signupUrl = '$baseUrl/api/auth/signup';
  static const String robotCommandUrl = '$baseUrl/api/robot/command';
  static const String dashboardLogsUrl = '$baseUrl/api/app/dashboard/logs';
}
