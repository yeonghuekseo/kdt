import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kdt/api_config.dart';
import 'app_widgets.dart';

// =============================================================================
// [3] 신규 사용자 회원가입 화면 (Signup Screen)
// =============================================================================
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController(text: 'KR');

  bool isLoading = false;

  /// [기능] 입력값 검증 후 서버에 회원등록 POST 요청 전송
  Future<void> _signup() async {
    final userId = _idController.text.trim();
    final password = _pwController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final country = _countryController.text.trim();

    if (userId.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 정보를 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse(ApiConfig.signupUrl);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'password': password,
          'name': name,
          'phone_number': phone,
          'email': email,
          'country': country,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${responseData['message']}')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${responseData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 회원가입 요청 실패: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍓 Ddalgi Farm 회원가입')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
              children: [
              // [수정] 모듈화된 커스텀 입력창들 사용
              CustomTextField(controller: _idController, labelText: '아이디 (user_id)'),
          const SizedBox(height: 12),
          CustomTextField(controller: _pwController, labelText: '비밀번호 (password)', isPassword: true),
          const SizedBox(height: 12),
          CustomTextField(controller: _nameController, labelText: '이름 (name)'),
          const SizedBox(height: 12),
          CustomTextField(controller: _phoneController, labelText: '전화번호 (phone_number)', keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          CustomTextField(controller: _emailController, labelText: '이메일 (email)', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          CustomTextField(controller: _countryController, labelText: '국가 (country)'),
          const SizedBox(height: 24),

          // [수정] 공통 메인 가입 버튼
          PrimaryButton(
            text: '가입하기',
            isLoading: isLoading,
            onPressed: _signup,
            ),
          ],
        ),
      ),
    );
  }
}