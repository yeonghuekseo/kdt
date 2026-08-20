// lib/services/service_crop_data.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class CropDataService {
  static const Map<String, Map<String, String>> _defaultMetadata = {
    'strawberry': {'name': '딸기', 'icon': '🍓'},
    'apple': {'name': '사과', 'icon': '🍎'},
    'grape': {'name': '포도', 'icon': '🍇'},
    'peach': {'name': '복숭아', 'icon': '🍑'},
  };

  static Future<List<String>> _fetchCropIdsFromServer(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['strawberry', 'apple', 'grape', 'peach'];
  }

  static Future<List<CropModel>> getMergedCropData(String userId) async {
    final serverCropIds = await _fetchCropIdsFromServer(userId);
    final prefs = await SharedPreferences.getInstance();
    final localDataString = prefs.getString('local_crop_metadata');

    Map<String, dynamic> localMetadata = {};
    // 🌟 손상된 로컬 데이터에 의한 FormatException 예외 처리
    if (localDataString != null) {
      try {
        final decoded = jsonDecode(localDataString);
        if (decoded is Map<String, dynamic>) {
          localMetadata = decoded;
        }
      } catch (e) {
        debugPrint('로컬 작물 메타데이터 파싱 오류: $e');
      }
    }

    List<CropModel> mergedList = [];
    for (String cropId in serverCropIds) {
      String name = localMetadata[cropId]?['name'] ?? _defaultMetadata[cropId]?['name'] ?? '작물';
      String icon = localMetadata[cropId]?['icon'] ?? _defaultMetadata[cropId]?['icon'] ?? '🌱';
      mergedList.add(CropModel(cropId: cropId, name: name, icon: icon));
    }
    return mergedList;
  }

  static Future<void> saveLocalCropMetadata(List<CropModel> crops) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> metadataToSave = {};
    for (var crop in crops) {
      metadataToSave[crop.cropId] = crop.toJson();
    }
    await prefs.setString('local_crop_metadata', jsonEncode(metadataToSave));
  }
}