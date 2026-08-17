// lib/services/service_auth.dart
import 'package:flutter/foundation.dart'; // debugPrint를 사용하기 위함
import '../core/api_config.dart';
import '../services/service_api.dart';

class AuthService {
  Future<Map<String, dynamic>> login({required String userId, required String password}) async {
    final url = ApiConfig.loginUrl;
    debugPrint('➡️ [로그인 요청] URL: $url, ID: $userId');

    //ApiService를 활용해 한 줄로 통신 및 파싱 완료
    final responseData = await ApiService.post(url, {
      'user_id' : userId,
      'password': password,
    });

    if(responseData != null) {
      bool isSuccess = responseData['status'] == 'success' || responseData['success'] == true;
      return{
        'success' : isSuccess,
        'message' : responseData['message'] ?? (isSuccess ? '로그인 성공' : '로그인 실패'),
        'data' : responseData['data'] ?? {'user_id' : userId, 'name' : '사용자'},
      };
    }
    return {'success' : false, 'message' : '서버 통신 실패 또는 응답 오류'};
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> requestData) async {
      final url = ApiConfig.signupUrl;
      debugPrint('➡️ [회원가입 요청] URL: $url, Data: $requestData');

      final responseData = await ApiService.post(url, requestData);

      if (responseData != null) {
        bool isSuccess = responseData['status'] == 'success' || responseData['success'] == true;
        return {
          'success' : isSuccess,
          'message' : responseData['message'] ?? (isSuccess ? '회원가입 성공' : '회원가입 실패'),
        };
      }
      return {'success' : false, 'message' : '회원가입 요청 실패'};
  }
}