// lib/app_theme.dart
import 'package:flutter/material.dart';

/// [공통 색상 팔레트] 앱 전체에서 사용되는 메인 컬러 정의
class AppColors {
  static const Color background = Color(0xC5EDCDA3);    // 전체 화면 세이지 올리브 배경색
  static const Color primary = Color(0xFF8A5F5F);       // 메인 로즈브라운 (앱바, 주 테마)
  static const Color buttonBg = Color(0x52ADB673);      // 골드 샌드 버 튼 배경색
  static const Color buttonText = Color(0xAEBA5039);    // 딸기 핑크/버건디 버튼 텍스트색
  static const Color inputBg = Color(0xF2F1E1C9);       // 아이보리 샌드 입력창 배경색
  static const Color inputLabel = Color(0xFF5A4444);    // 라벨 및 안내 텍스트 색상
  static const Color linkText = Color(0xFF9D90CC);      // 텍스트 버튼/링크 색상
  static const Color alertCardBg = Color(0xFFFFEBEE);   // 경고 패널 및 카드 연분홍 배경
}

/// [공통 디자인 테마]
class AppTheme {
  // 입력창 공통 스타일 생성 헬퍼 함수
  static InputDecoration inputDecoration(String labelText, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: AppColors.inputBg,
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.buttonText, width: 2.0),
      ),
      labelStyle: const TextStyle(color: AppColors.inputLabel),
      suffixIcon: suffixIcon,
    );
  }

  // MaterialApp에 일괄 적용할 ThemeData
  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      useMaterial3: true,
    );
  }
}