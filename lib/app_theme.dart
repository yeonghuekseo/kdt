// lib/app_theme.dart
import 'package:flutter/material.dart';

/// [공통 색상 팔레트] 앱 전체에서 사용되는 메인 컬러 정의
class AppColors {
  static const Color background = Color(0xFFEDCDA3);    // 전체 화면 세이지 올리브 배경색
  static const Color primary = Color(0xFF8A5F5F);       // 메인 로즈브라운 (앱바, 주 테마)
  static const Color buttonBg = Color(0xFFADB673);      // 골드 샌드 버 튼 배경색
  static const Color buttonText = Color(0xFFBA5039);    // 딸기 핑크/버건디 버튼 텍스트색
  static const Color inputBg = Color(0xFFF1E1C9);       // 아이보리 샌드 입력창 배경색
  static const Color inputLabel = Color(0xFF5A4444);    // 라벨 및 안내 텍스트 색상
  static const Color linkText = Color(0xFF9D90CC);      // 텍스트 버튼/링크 색상
  static const Color alertCardBg = Color(0xFFFFEBEE);   // 경고 패널 및 카드 연분홍 배경
  //대시보드 및 로봇 제어 패널색상
  static const Color robotPanelBg = Color(0xFFFFEBEE);  //  로봇 제어 패널 배경색
  static const Color sliderThumb = Color(0xFFFFCC80);   //  슬라이더 손잡이 (주황)
  static const Color sliderActive = Color(0xFFE57373);  //  슬라이더 동작 상태 색상
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
        //버튼의 기본 스타일
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBg,
            foregroundColor: AppColors.buttonText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      useMaterial3: true,
    );
  }
}

/* ============================================================================= */
/* [신규 추가] Theme 파일 하단에 통합 작성한 공통 유효성 검사 클래스            */
/* ============================================================================= */
class AppValidators {
  // 1. 아이디 검사 (필수 + 4자 이상)
  static String? validateId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '아이디를 입력해주세요.';
    }
    if (value.trim().length < 4) {
      return '아이디는 4자 이상이어야 합니다.';
    }
    return null;
  }

  // 2. 비밀번호 검사 (필수 + 6자 이상)
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (value.trim().length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    return null;
  }

  // 3. 이름 검사 (필수 + 2자 이상)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요.';
    }
    if (value.trim().length < 2) {
      return '이름은 2자 이상 입력해주세요.';
    }
    return null;
  }

  // 4. 전화번호 검사 (필수 + 정규식)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    final phoneRegExp = RegExp(r'^\d{2,3}-?\d{3,4}-?\d{4}$');
    if (!phoneRegExp.hasMatch(value.trim())) {
      return '올바른 전화번호 형식이 아닙니다.';
    }
    return null;
  }

  // 5. 이메일 검사 (필수 + 정규식)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return '올바른 이메일 형식이 아닙니다. (예: user@example.com)';
    }
    return null;
  }

  // 6. 국가 검사 (선택 항목 + 입력 시 정규식)
  static String? validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 선택 항목이므로 비어있으면 통과
    }
    final countryRegExp = RegExp(r'^[a-zA-Z]{2,3}$');
    if (!countryRegExp.hasMatch(value.trim())) {
      return '국가 코드는 2~3자리 영문입니다. (예: KR, US)';
    }
    return null;
  }
}