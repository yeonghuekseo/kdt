// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // 공통 GET 요청 메서드
  static Future<Map<String, dynamic>?> get(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // 성공 시 파싱된 데이터 반환
      } else {
        debugPrint('❌ API 에러 (상태 코드: ${response.statusCode})');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 네트워크 예외 발생: $e');
      return null;
    }
  }

  // 공통 POST 요청 메서드 (명령 전송 등에서 활용 가능)
  static Future<Map<String, dynamic>?> post(String url, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint('❌ API 에러 (상태 코드: ${response.statusCode})');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 네트워크 예외 발생: $e');
      return null;
    }
  }
}