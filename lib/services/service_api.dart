// lib/services/service_api.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// API 요청 결과를 담는 클래스
class ApiResult {
  final bool success;
  final dynamic data;
  final String message;

  ApiResult({required this.success, this.data, this.message = ''});
}

class ApiService {
  // 공통 GET 요청 메서드
  static Future<ApiResult> get(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ApiResult(
          success: true,
          data: jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        debugPrint('❌ API 에러 (상태 코드: ${response.statusCode})');
        return ApiResult(success: false, message: '서버 오류 (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ 네트워크 예외 발생: $e');
      return ApiResult(success: false, message: '네트워크 연결이 원활하지 않습니다.');
    }
  }

  // 공통 POST 요청 메서드
  static Future<ApiResult> post(String url, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult(
          success: true,
          data: jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        debugPrint('❌ API 에러 (상태 코드: ${response.statusCode})');
        return ApiResult(success: false, message: '서버 오류 (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ 네트워크 예외 발생: $e');
      return ApiResult(success: false, message: '네트워크 연결이 원활하지 않습니다.');
    }
  }
}
