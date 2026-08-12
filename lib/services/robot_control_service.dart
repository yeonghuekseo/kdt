// lib/robot_control_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

/// 로봇 제어와 관련된 비즈니스 로직 및 API 통신을 전담하는 서비스 클래스
class RobotControlService {
  // 중복 신호 방지를 위한 이전 전송 명령 상태 기록 변수
  String _lastSentCommand = 'stop';

  // [네트워크 API 통신함수]
  Future<void> sendCommandToRobot({
    required String userId,
    required String robotId,
    required String command,
    String? zoneId, // 선택 사항
    required Function(String) onError
  }) async {
    try {
      final url = Uri.parse(ApiConfig.robotCommandUrl);

      final Map<String, dynamic> requestBody = {
        'user_id': userId,
        'robot_id': robotId,
        'command': command,
      };

      if (zoneId != null && zoneId.isNotEmpty) {
        requestBody['zone_id'] = zoneId;
      }

      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // [슬라이더 조작 헬퍼 함수]
  void sendSingleCommandForValue({
    required double targetValue,
    required String userId,
    required String robotId,
    String? zoneId,
    required Function(String) onError
  }) {
    String newCommand = (targetValue == 1.0) ? 'start_patrol' : 'stop';

    if (_lastSentCommand != newCommand) {
      _lastSentCommand = newCommand;
      sendCommandToRobot(
          userId: userId,
          robotId: robotId,
          command: newCommand,
          zoneId: zoneId,
          onError: onError
      );
    }
  }
}