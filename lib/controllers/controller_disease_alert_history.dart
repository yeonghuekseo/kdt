// lib/controllers/controller_disease_alert_history.dart
import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../services/service_api.dart'; // 🌟 ApiService 임포트

class DiseaseAlertHistoryController extends ChangeNotifier {
  List<dynamic> diseaseLogs = [];
  bool isLoading = false;

  Future<void> fetchDiseaseLogs(String userId) async {
    isLoading = true;
    notifyListeners();

    // 🌟 여기도 ApiService 재사용
    final url = ApiConfig.cropLogsUrl(userId);
    final responseData = await ApiService.get(url);

    if (responseData != null && responseData['status'] == 'success' && responseData['data'] != null) {
      diseaseLogs = responseData['data'];
    } else {
      diseaseLogs = [];
    }

    isLoading = false;
    notifyListeners();
  }
}