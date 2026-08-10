// lib/robot_control_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// 로봇 제어와 관련된 비즈니스 로직 및 API 통신을 전담하는 서비스 클래스
class RobotControlService {
  // 중복 신호 방지를 위한 이전 전송 명령 상태 기록 변수
  String _lastSentCommand = 'stop';

  // [네트워크 API 통신함수]
  // 기능> 백엔드 서버로 로봇 제어 명령(stop, start_patrol, return_home) 전송(REST POST)
  Future<void> sendCommandToRobot(String command, String targetZone, {required Function(String) onError}) async {
    try {
      final url = Uri.parse(ApiConfig.robotCommandUrl);

      final Map<String, dynamic> requestBody = {
        'command': command, // 명령어 (start_patrol, return_home 등)
        'target_zone': targetZone, // 목표 구역 식별자
        'timestamp': DateTime.now().toString().substring(0,19) // 전송시간
      };

      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
    } catch (e) {
      // 오류 발생 시 UI(화면) 쪽으로 에러 메시지 전달
      onError(e.toString());
    }
  }

  // [슬라이더 조작 헬퍼 함수]
  // 기능>> 슬라이더 이동 완료 후 값을 확인하여 백엔드로 알맞은 명령 1회 전송
  void sendSingleCommandForValue(double targetValue, String targetZone, {required Function(String) onError}) {
    String newCommand = (targetValue == 1.0) ? 'start_patrol' : 'stop';

    // 기존 명령과 다를 때만 (실제 상태가 전환되었을 때만) 단 한 번 신호 전송
    if (_lastSentCommand != newCommand) {
      _lastSentCommand = newCommand;   // 마지막 전송 상태 갱신
      sendCommandToRobot(newCommand, targetZone, onError: onError); // 백엔드로 신호 1회 전송
    }
  }
}