// lib/services/service_auth.dart
import 'package:flutter/foundation.dart';
import '../core/api_config.dart';
import 'service_api.dart'; // 동일 폴더 내 import 수정

class AuthService {
  Future<Map<String, dynamic>> login({required String userId, required String password}) async {
    final url = ApiConfig.loginUrl;
    debugPrint('➡️ [로그인 요청] URL: $url, ID: $userId');

    // 🌟 ApiResult 타입을 명시적으로 지정하여 혼동 방지
    final ApiResult result = await ApiService.post(url, {
      'user_id' : userId,
      'password': password,
    });

    if(result.success && result.data != null) {
      // 🌟 데이터 타입을 Map으로 명시적 캐스팅
      final Map<String, dynamic> responseData = result.data as Map<String, dynamic>;
      bool isSuccess = responseData['status'] == 'success' || responseData['success'] == true;
      
      return {
        'success' : isSuccess,
        'message' : responseData['message'] ?? (isSuccess ? '로그인 성공' : '로그인 실패'),
        'data' : responseData['data'] ?? {'user_id' : userId, 'name' : '사용자'},
      };
    }
    return {'success' : false, 'message' : result.message.isNotEmpty ? result.message : '서버 통신 실패 또는 응답 오류'};
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> requestData) async {
      final url = ApiConfig.signupUrl;
      debugPrint('➡️ [회원가입 요청] URL: $url, Data: $requestData');

      final ApiResult result = await ApiService.post(url, requestData);

      if (result.success && result.data != null) {
        final Map<String, dynamic> responseData = result.data as Map<String, dynamic>;
        bool isSuccess = responseData['status'] == 'success' || responseData['success'] == true;

        return {
          'success' : isSuccess,
          'message' : responseData['message'] ?? (isSuccess ? '회원가입 성공' : '회원가입 실패'),
        };
      }
      return {'success' : false, 'message' : result.message.isNotEmpty ? result.message : '회원가입 요청 실패'};
  }
}
