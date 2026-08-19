// lib/providers/crop_provider.dart
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/service_crop_data.dart';

// 🌟 [전역화 수정 포인트] 작물 리스트를 앱 전역에서 언제든 꺼내볼 수 있도록 Provider화
class CropProvider extends ChangeNotifier {
  List<CropModel> _crops = [];
  bool _isLoading = true;

  List<CropModel> get crops => _crops;
  bool get isLoading => _isLoading;

  // 앱 초기화 시 호출
  Future<void> fetchCrops(String userId) async {
    _isLoading = true;
    notifyListeners();

    _crops = await CropDataService.getMergedCropData(userId);

    _isLoading = false;
    notifyListeners();
  }

  // 설정 화면 등에서 수정 후 호출
  Future<void> updateAndSaveCrops(List<CropModel> newCrops) async {
    _crops = List.from(newCrops);
    notifyListeners(); // 🌟 수정 즉시 메인 화면, 대시보드 등 모든 뷰가 자동 갱신됨
    await CropDataService.saveLocalCropMetadata(newCrops);
  }
}