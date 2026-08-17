import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/screen_login.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';

// [앱 시작점] 앱의 최상위 위젯. 공통 테마를 주입하고 첫 화면을 지정합니다.
void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child:const MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kdt1조 스마트팜(딸기딸기)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData, //중앙 통합 관리되는 테마 적용
      home: const LoginScreen(), //앱 실행시 로그인 화면으로 최초 진입
    );
  }
}