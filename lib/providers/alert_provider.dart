// lib/providers/alert_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../services/service_api.dart';
import '../services/service_mqtt.dart';

class AlertProvider extends ChangeNotifier {
  List<Map<String, dynamic>> alertLogs = [];
  List<Map<String, dynamic>> inspectionLogs = [];
  bool isLoading = false;
  
  // 🌟 MQTT 연결 상태 게터 추가
  bool get isConnected => MqttService().isConnected;
  
  static const int _maxLogCount = 100;
  bool _isDisposed = false;
  StreamSubscription? _mqttSubscription;
  Timer? _throttleTimer; // 🌟 리빌드 과부하 방지용 타이머

  @override
  void dispose() {
    _isDisposed = true;
    _mqttSubscription?.cancel();
    _throttleTimer?.cancel();
    super.dispose();
  }

  // 🌟 성능 최적화: notifyListeners를 너무 자주 호출하지 않음 (최대 0.5초 간격)
  void _throttledNotify() {
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_isDisposed) notifyListeners();
    });
  }

  void init(String userId) {
    MqttService().connect(userId);
    _fetchHistoryLogs(userId);

    _mqttSubscription?.cancel();
    _mqttSubscription = MqttService().messageStream.listen((data) {
      final topic = data['topic']?.toString() ?? '';
      bool changed = false;

      if (topic == ApiConfig.diseaseAlertTopic(userId)) {
        _addLogToList(alertLogs, data);
        _addLogToList(inspectionLogs, data);
        changed = true;
      } else if (topic == 'ddalgi/robot/status' && data.containsKey('health_status')) {
        _addLogToList(inspectionLogs, data);
        changed = true;
      }

      if (changed) _throttledNotify();
    });
  }

  void _addLogToList(List<Map<String, dynamic>> list, Map<String, dynamic> data) {
    list.insert(0, data);
    if (list.length > _maxLogCount) list.removeLast();
  }

  Future<void> _fetchHistoryLogs(String userId) async {
    isLoading = true;
    notifyListeners();

    final result = await ApiService.get(ApiConfig.cropLogsUrl(userId));
    if (result.success && result.data != null) {
      final List<dynamic> logs = result.data['data'] ?? [];
      alertLogs.clear();
      inspectionLogs.clear();
      for (var log in logs) {
        final logMap = Map<String, dynamic>.from(log);
        _addLogToList(inspectionLogs, logMap);
        if (['경고', '위험'].contains(logMap['health_status'])) {
          _addLogToList(alertLogs, logMap);
        }
      }
    }
    isLoading = false;
    notifyListeners();
  }
}
