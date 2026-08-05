import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'app_theme.dart';

// =============================================================================
// [1] 앱 시작점 (Main Entry Point)
// =============================================================================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kdt1조 스마트팜(딸기딸기)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData, //중앙 통합 관리되는 AppTheme.themeData 적용
      //앱 실행시 로그인 화면으로 최초 진입
      home: const LoginScreen(),
    );
  }
}