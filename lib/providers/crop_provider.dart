// lib/providers/crop_provider.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/app_models.dart';
import '../services/service_crop_data.dart';
import '../core/app_constants.dart';

class CropProvider extends ChangeNotifier {
  List<CropModel> _crops = [];
  bool _isLoading = true;

  // 🌟 데이터를 RipenessData 클래스 타입으로 통일하여 저장
  final Map<String, List<RipenessData>> _ripenessCache = {}; 
  final Map<String, HarvestRange> _harvestPeriods = {}; 

  List<CropModel> get crops => _crops;
  bool get isLoading => _isLoading;
  Map<String, HarvestRange> get harvestPeriods => _harvestPeriods;

  Future<void> fetchCrops(String userId) async {
    _isLoading = true;
    notifyListeners();
    _crops = await CropDataService.getMergedCropData(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> preCalculateAllHarvest(String userId) async {
    final random = math.Random();
    final now = DateTime.now();

    for (var crop in _crops) {
      List<RipenessData> dummyData = List.generate(7, (index) {
        final dateStr = '${now.subtract(Duration(days: 6 - index)).month.toString().padLeft(2,'0')}/${now.subtract(Duration(days: 6 - index)).day.toString().padLeft(2,'0')}';
        int unripe = 2 + random.nextInt(10);
        int ripe = 40 + random.nextInt(40);
        int over = random.nextInt(8);
        
        // 🌟 Map이 아닌 클래스 객체 생성
        return RipenessData(date: dateStr, unripeCount: unripe, ripeCount: ripe, overripeCount: over);
      });

      updateHarvestPrediction(crop.cropId, dummyData);
    }
  }

  void updateHarvestPrediction(String cropId, List<RipenessData> ripenessData) {
    _ripenessCache[cropId] = ripenessData;
    
    for (var data in ripenessData) {
      try {
        final int total = data.unripeCount + data.ripeCount + data.overripeCount;
        if (total > 0 && (data.unripeCount / total < 0.1) && (data.ripeCount / total >= 0.75)) {
          final crop = _crops.firstWhere((c) => c.cropId == cropId, orElse: () => CropModel(cropId: cropId, name: '작물', icon: '🌱'));
          List<String> parts = data.date.split('/');
          DateTime foundDate = DateTime(DateTime.now().year, int.parse(parts[0]), int.parse(parts[1]));
          
          _harvestPeriods[cropId] = HarvestRange(
            start: foundDate.add(const Duration(days: 7)),
            end: foundDate.add(const Duration(days: 13)),
            fruitIcon: crop.icon,
            fruitName: crop.name,
          );
          break;
        }
      } catch (e) {
        debugPrint('Harvest calculation error: $e');
      }
    }
    notifyListeners();
  }

  List<RipenessData>? getCachedRipeness(String cropId) => _ripenessCache[cropId];
}
