// lib/controllers/controller_robot_history.dart
import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../services/api_service.dart'; // 🌟 ApiService 임포트

class RobotHistoryController extends ChangeNotifier {
  List<dynamic> historyLogs = [];
  bool isLoading = false;

  Future<void> fetchHistoryLogs(String userId) async {
    isLoading = true;
    notifyListeners();

    // 🌟 ApiService를 이용해 데이터 호출 (코드가 극적으로 짧아짐)
    final url = ApiConfig.commandLogsUrl(userId);
    final responseData = await ApiService.get(url);

    // 받아온 데이터 가공 및 상태 저장
    if (responseData != null && responseData['status'] == 'success' && responseData['data'] != null) {
      historyLogs = responseData['data'];
    } else {
      historyLogs = [];
    }

    isLoading = false;
    notifyListeners();
  }
}