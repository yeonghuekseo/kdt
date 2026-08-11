import 'package:flutter/material.dart';
import '../widgets/app_widgets.dart'; // 수정: widgets 폴더
import '../core/app_validators.dart'; // 수정: core 폴더 내 분리된 클래스 사용
import '../services/auth_service.dart'; // 수정: 서비스 클래스 사용

// =============================================================================
//  신규 사용자 회원가입 화면 (Signup Screen)
// =============================================================================
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();            //폼 상태 제어하고 유효성 검사 총괄
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController(text: 'KR');

  final AuthService _authService = AuthService(); // 서비스 연동

  bool isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  /// [기능] Form 유효성 및 정규식 검증 후 서버에 POST 요청 전송
  Future<void> _signup() async {
    // Form 내 모든 TextFormField의 validator 실행 (하나라도 통과 실패 시 중단)
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 입력 양식을 다시 확인해 주세요.')),
      );
      return;
    }

    setState(() => isLoading = true);

    final Map<String, dynamic> requestData = {
      'user_id': _idController.text.trim(),
      'password': _pwController.text.trim(),
      'name': _nameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'country': _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : 'KR', //선택항목 처리
    };

    final result = await _authService.signup(requestData);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${result['message']}')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ${result['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍓 Ddalgi Farm 회원가입')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          //전체 입력 양식을 Form 위젯으로 감싸서 통합 관리
          child: Form(
            key: _formKey,  //_formKey연결
            child: Column(
              children: [
                const Text(
                  '*표시 항목은 필수 입력 항목입니다.',
                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                //아이디(필수 + 4자 이상 검사)
                CustomTextField(
                  controller: _idController,
                  labelText: '아이디 *',
                  validator: AppValidators.validateId
                ),
                const SizedBox(height: 12),

                //비밀번호 (필수 + 3자 이상 검사)
                CustomTextField(
                    controller: _pwController,
                    labelText: '비밀번호 *',
                    isPassword: true,
                    validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 12),

                //이름 (이름 + 2자 이상 검사)
                CustomTextField(
                    controller: _nameController,
                    labelText: '이름 *',
                    validator: AppValidators.validateName,
                    ),
                    const SizedBox(height: 12),

                //전화번호 (필수+ 정규식 형식 검사)
                CustomTextField(
                  controller: _phoneController,
                  labelText: '전화번호 *',
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.validatePhone,
                ),
                const SizedBox(height: 12),

                //이메일
                CustomTextField(
                    controller: _emailController,
                    labelText: '이메일 *',
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                    controller: _countryController,
                    labelText: '국가',
                    validator: AppValidators.validateCountry,
                ),
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
        ),
    );
  }
}