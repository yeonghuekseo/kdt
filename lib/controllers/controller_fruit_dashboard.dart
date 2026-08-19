// lib/controllers/controller_fruit_dashboard.dart
import 'package:flutter/foundation.dart';
import '../core/api_config.dart';
import '../services/service_api.dart';

class RipenessData {
  final String date;
  final int unripeCount, ripeCount, overripeCount;
  RipenessData({required this.date, required this.unripeCount, required this.ripeCount, required this.overripeCount});
}

class FruitDashboardController extends ChangeNotifier {
  final String userId;
  final String fruitCode;
  List<RipenessData> ripenessList = [];

  FruitDashboardController({required this.userId, required this.fruitCode}) {
    _loadRipenessData();
  }

  Future<void> _loadRipenessData() async {
    final summaryUrl = ApiConfig.cropSummaryUrl(userId, fruitCode);
    final summaryResponse = await ApiService.get(summaryUrl);

    if (summaryResponse != null && summaryResponse['status'] == 'success' && summaryResponse['data'] != null) {
      final data = summaryResponse['data'];
      if (data.containsKey('growth_ranges') && data['growth_ranges'] is List) {
        ripenessList = (data['growth_ranges'] as List).map((item) => RipenessData(
          date: item['date']?.toString() ?? '알수없음',
          unripeCount: int.tryParse(item['unripe']?.toString() ?? '0') ?? 0,
          ripeCount: int.tryParse(item['ripe']?.toString() ?? '0') ?? 0,
          overripeCount: int.tryParse(item['overripe']?.toString() ?? '0') ?? 0,
        )).toList();
      }
    }
    notifyListeners();
  }
}