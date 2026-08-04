import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'signup_screen.dart';
import 'screen_selection.dart';
import 'api_config.dart';

// =============================================================================
// [2] 사용자 로그인 화면 (Login Screen)
// =============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool isLoading = false;

  /// [기능] 서버로 로그인 데이터(JSON) 전송 및 결과 처리
  Future<void> _login() async {
    final userId = _idController.text.trim();
    final password = _pwController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse(ApiConfig.loginUrl);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'password': password,
        }),
      );

      final isJson = response.headers['content-type']?.contains('application/json') ?? false;

      if (isJson) {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final String loggedInUserId = responseData['data']['user_id'];
          final String loggedInName = responseData['data']['name'];

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ ${responseData['message']}')),
          );

          // 메인 대시보드로 이동하며 사용자 정보 전달
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FruitSelectionScreen(
                currentUserId: loggedInUserId,
                currentUserName: loggedInName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${responseData['message']}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 서버 연결 실패: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB6B696),
      appBar: AppBar(title: const Text('🍓 Ddalgi Farm 로그인'),backgroundColor: Color(
          0xFF8A5F5F)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID',

                filled: true,
                fillColor: const Color(0xF2F1E1C9),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PW',

                filled: true,
                fillColor: const Color(0xF2F1E1C9),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE9E67),
                    foregroundColor: const Color(0xFFBD4A8C),
                ),
                onPressed: _login,
                child: const Text('로그인', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF90A1CC),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text('계정이 없으신가요? 회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}