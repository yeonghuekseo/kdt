import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/api_config.dart';
import '../services/service_api.dart';

class EnvironmentProvider extends ChangeNotifier {
  // 1. 상태 데이터 선언 (온도, 습도 차트 스팟 리스트)
  List<FlSpot> _tempSpots = [
    const FlSpot(0, 22), const FlSpot(1, 24), const FlSpot(2, 23), const FlSpot(3, 26), const FlSpot(4, 25)
  ];
  List<FlSpot> _humidSpots = [
    const FlSpot(0, 60), const FlSpot(1, 62), const FlSpot(2, 58), const FlSpot(3, 65), const FlSpot(4, 63)
  ];

  bool _isLoading = false;

  // 2. 외부에서 안전하게 읽을 수 있도록 Getter 제공 (Encapsulation)
  List<FlSpot> get tempSpots => _tempSpots;
  List<FlSpot> get humidSpots => _humidSpots;
  bool get isLoading => _isLoading;

  // 3. 서버 통신을 통해 실제 온습도 데이터를 가져오는 메서드 (심화 로직)
  Future<void> fetchEnvironmentLogs(String userId) async {
    _isLoading = true;
    notifyListeners(); // 로딩 시작을 화면에 알림

    final url = ApiConfig.envLogsUrl(userId);
    final responseData = await ApiService.get(url);

    if (responseData != null && responseData['status'] == 'success' && responseData['data'] != null) {
      final List<dynamic> logs = responseData['data'];
      List<FlSpot> loadedTemp = [];
      List<FlSpot> loadedHumid = [];

      for (int i = 0; i < logs.length; i++) {
        double tValue = (logs[i]['temperature'] ?? 0.0).toDouble();
        double hValue = (logs[i]['humidity'] ?? 0.0).toDouble();
        loadedTemp.add(FlSpot(i.toDouble(), tValue));
        loadedHumid.add(FlSpot(i.toDouble(), hValue));
      }

      // 파싱된 데이터가 있다면 상태 교체
      if (loadedTemp.isNotEmpty) {
        _tempSpots = loadedTemp;
        _humidSpots = loadedHumid;
      }
    }

    _isLoading = false;
    notifyListeners(); // 데이터 갱신 완료를 화면에 알림
  }
}