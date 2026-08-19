// lib/providers/alert_provider.dart
import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../services/service_api.dart';
import '../services/service_mqtt.dart';

// 🌟 [전역화 수정 포인트] 알림 및 이력 데이터를 앱 전역에서 백그라운드로 수집 및 공유
class AlertProvider extends ChangeNotifier {
  List<Map<String, dynamic>> alertLogs = [];
  List<Map<String, dynamic>> inspectionLogs = [];
  bool get isConnected => MqttService().isConnected;
  bool isLoading = false;

  void init(String userId) {
    MqttService().connect(userId);
    _fetchHistoryLogs(userId);

    MqttService().messageStream.listen((data) {
      final topic = data['topic']?.toString() ?? '';

      // 질병 경고 토픽인 경우
      if (topic == ApiConfig.diseaseAlertTopic(userId)) {
        alertLogs.insert(0, data);
        inspectionLogs.insert(0, data);
        notifyListeners(); // 뱃지 카운트 자동 증가
      }

      // 로봇 일반 상태 토픽인 경우 (일반 조회 이력 추가)
      if (topic == 'ddalgi/robot/status' && data.containsKey('health_status')) {
        // 중복 검사 로직 등을 거친 후 추가 가능
        inspectionLogs.insert(0, data);
        notifyListeners();
      }
    });
  }

  Future<void> _fetchHistoryLogs(String userId) async {
    isLoading = true;
    notifyListeners();

    final url = ApiConfig.cropLogsUrl(userId);
    final responseData = await ApiService.get(url);

    if (responseData != null && responseData['status'] == 'success' && responseData['data'] != null) {
      final List<dynamic> logs = responseData['data'];
      alertLogs.clear();
      inspectionLogs.clear();

      for (var log in logs) {
        final logMap = Map<String, dynamic>.from(log);
        inspectionLogs.add(logMap);

        final status = logMap['health_status']?.toString() ?? '';
        if (status == '경고' || status == '위험') {
          alertLogs.add(logMap);
        }
      }
    }
    isLoading = false;
    notifyListeners();
  }
}