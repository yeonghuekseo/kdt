import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

/// [작물 데이터 서비스] 서버의 작물 코드와 로컬의 메타데이터를 병합 및 영구 저장합니다.
class CropDataService {
  //1. 기본 데이터 기기에 저장된 설정이 없을 때 사용할 기본 디자인
  static const Map<String, Map<String, String>> _defaultMetadata = {
    'strawberry': {'name': '딸기', 'icon': '🍓'},
    'apple': {'name': '사과', 'icon': '🍎'},
    'grape': {'name': '포도', 'icon': '🍇'},
    'peach': {'name': '복숭아', 'icon': '🍑'},
  };
  // [2. 서버 통신부] 서버에서 유저의 작물 ID(crop_id) 목록만 가져오기
  static Future<List<String>> _fetchCropIdsFromServer(String userId) async {
      await Future.delayed(const Duration(milliseconds: 500)); // 통신 지연 시뮬레이션
      return ['strawberry', 'apple', 'grape', 'peach'];
  }
  // [3. 데이터 병합부] 서버의 crop_id와 기기에 저장된 커스텀 이름/아이콘 합치기
  static Future<List<CropModel>> getMergedCropData(String userId) async {
    final serverCropIds = await _fetchCropIdsFromServer(userId);
    final prefs = await SharedPreferences.getInstance();
    final localDataString = prefs.getString('local_crop_metadata');

    Map<String, dynamic> localMetadata = {};
    if (localDataString != null) {
      localMetadata = jsonDecode(localDataString);
    }

    List<CropModel> mergedList = [];
    for (String cropId in serverCropIds) {
      String name = localMetadata[cropId]?['name'] ?? _defaultMetadata[cropId]?['name'] ?? '작물';
      String icon = localMetadata[cropId]?['icon'] ?? _defaultMetadata[cropId]?['icon'] ?? '🌱';

      mergedList.add(CropModel(cropId: cropId, name: name, icon: icon));
    }
    return mergedList;
  }
  // [4. 데이터 저장부] 사용자가 수정한 이름과 아이콘을 기기에 영구 저장
  static Future<void> saveLocalCropMetadata(List<CropModel> crops) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> metadataToSave = {};

    for (var crop in crops) {
      metadataToSave[crop.cropId] = crop.toJson();
    }
    await prefs.setString('local_crop_metadata', jsonEncode(metadataToSave));
  }
}