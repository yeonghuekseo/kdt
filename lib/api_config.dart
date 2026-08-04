// lib/api_config.dart

class ApiConfig {
  // 1. 서버 IP 및 포트 설정 (이곳만 변경하면 전체 앱에 적용됨)
  static const String serverIp = '192.168.0.6'; // 백엔드 서버 IP
  static const int restPort = 12345;              // HTTP REST API 포트
  static const int mqttPort = 1883;               // MQTT 포트

  // 2. Base URL 정의
  static const String baseUrl = 'http://$serverIp:$restPort';

  // 3. API 엔드포인트 URL 모음
  static const String loginUrl = '$baseUrl/api/auth/login';
  static const String signupUrl = '$baseUrl/api/auth/signup';
  static const String robotCommandUrl = '$baseUrl/api/robot/command';
  static const String dashboardLogsUrl = '$baseUrl/api/app/dashboard/logs';
}