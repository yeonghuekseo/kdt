// lib/services/service_auth.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // debugPrint를 사용하기 위함
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

/// 서버로 로그인 및 회원가입 데이터(JSON) 전송 및 결과 처리를 전담하는 서비스 클래스
class AuthService {

  /// [기능] 서버로 로그인 요청
  Future<Map<String, dynamic>> login({required String userId, required String password}) async {
    try {
      final url = Uri.parse(ApiConfig.loginUrl);

      // 디버그 로그: 어떤 주소와 데이터로 보내는지 확인
      debugPrint('➡️ [로그인 요청] URL: $url, ID: $userId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'password': password,
        }),
      );

      // 디버그 로그: 서버에서 온 날것의 응답 데이터 확인
      debugPrint('⬅️ [로그인 응답] 상태코드: ${response.statusCode}, Body: ${response.body}');

      // 헤더 검사 대신, 직접 JSON 파싱을 시도하는 안전한 방식(try-catch) 도입
      try {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 백엔드가 'data' 필드를 안 줬을 경우를 대비해 null 체크 보완
          return {
            'success': true,
            'message': responseData['message'] ?? '로그인 성공',
            'data': responseData['data'] ?? {'user_id': userId, 'name': '사용자'},
          };
        } else {
          return {'success': false, 'message': responseData['message'] ?? '로그인 실패 (상태코드: ${response.statusCode})'};
        }
      } catch (e) {
        // 백엔드가 JSON이 아닌 HTML 에러 페이지 등을 보냈을 때 처리
        return {'success': false, 'message': '서버 응답 오류 (JSON 형식 아님)'};
      }

    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패: $e'};
    }
  }

  /// [기능] 서버로 회원가입 요청
  Future<Map<String, dynamic>> signup(Map<String, dynamic> requestData) async {
    try {
      final url = Uri.parse(ApiConfig.signupUrl);

      debugPrint('➡️ [회원가입 요청] URL: $url, Data: $requestData');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      debugPrint('⬅️ [회원가입 응답] 상태코드: ${response.statusCode}, Body: ${response.body}');

      // 회원가입에도 동일하게 안전한 JSON 파싱 적용
      try {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {'success': true, 'message': responseData['message'] ?? '회원가입 성공'};
        } else {
          return {'success': false, 'message': responseData['message'] ?? '회원가입 실패'};
        }
      } catch (e) {
        return {'success': false, 'message': '서버 응답 오류 (JSON 형식 아님)'};
      }

    } catch (e) {
      return {'success': false, 'message': '회원가입 요청 실패: $e'};
    }
  }
}