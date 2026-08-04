import 'package:flutter/material.dart';
import 'login_screen.dart';

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
      title: '딸기 농장 모니터링 및 제어',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      // 앱 실행 시 로그인 화면으로 최초 진입
      home: const LoginScreen(),
    );
  }
}