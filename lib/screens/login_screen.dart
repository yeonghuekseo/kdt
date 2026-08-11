import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'screen_selection.dart';
import '../widgets/app_widgets.dart'; // 공통 버튼 & 입력창 컴포넌트 import (경로수정)
import '../services/auth_service.dart'; // AuthService 적용

// =============================================================================
// [2] 사용자 로그인 화면 (Login Screen)
// =============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  //위젯의 상태를 관리하는 State 객체 생성
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
//LoginScreen의 실제 상태(State) 변화 및 렌더링 로직을 담는 클래스
class _LoginScreenState extends State<LoginScreen> {

  //입력 필드의 텍스트 제어 및 조화를 위한 Controller 객체 생성
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  final AuthService _authService = AuthService(); // 분리된 서비스 클래스

  bool isLoading = false; //로그인 요청 진행 여부 상태 (true: 로딩 중,false: 대기 중)

  // 메모리 누수 방지(Memory Leak Prevention)를 위한 dispose() 메서드
  @override
  void dispose() {
    _idController.dispose(); //  ID 입력 컨트롤러 해제
    _pwController.dispose(); //  PW 입력 컨트롤러 해제
    super.dispose();
  }

  /// [기능] 서버로 로그인 데이터(JSON) 전송 및 결과 처리
  Future<void> _login() async {
    //Controller에서 입력받은 텍스트를 가져오고 앞뒤 공백(.trim())제거
    final userId = _idController.text.trim();
    final password = _pwController.text.trim();

    //1. 예외 처리: 아이디 또는 비밀번호가 비어있는 경우
    if (userId.isEmpty || password.isEmpty) {
      // 화면 하단에 메시지 팝업(SnackBar)을 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')),
      );
      return;
    }
    //2. 로딩 시작: 화면 업데이트를 위해 setState 호출
    setState(() => isLoading = true);

    //3. 분리된 AuthService를 통해 로그인 시도
    final result = await _authService.login(userId: userId, password: password);

    // 위젯이 화면 트리에 여전히 존재(mounted)하는지 확인 (비동기 처리 후 안전한 UI변경을 위함)
    if (!mounted) return;

    // 통신이 끝나면 로딩상태 해제
    setState(() => isLoading = false);

    if(result['success']){
    //로그인 성공 스낵바 안내
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ ${result['message']}')),
    );

    final userData = result['data'];

    // 메인 대시보드로 이동하며 사용자 정보 전달 (이전 로그인 화면은 Navigator에서 제거)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FruitSelectionScreen(
          currentUserId: userData['user_id'],
          currentUserName: userData['name'],
        ),
      ),
    );
  } else {
  //HTTP 응답이 성공(200)이 아닌 경우 (예: 로그인 실패 400/401 등)
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('❌ ${result['message']}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍓 Ddalgi Farm 로그인')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 공통 ID 입력창
            CustomTextField(
                controller: _idController,
                labelText: 'ID',
              ),
              const SizedBox(height: 16),

            //비밀번호 입력 필드
              CustomTextField(
                controller: _pwController,
                labelText: 'PW',
                isPassword: true,
                ),
              const SizedBox(height: 24),

            // 공통 메인 버튼
            PrimaryButton(
              text: '로그인',
              isLoading: isLoading,
              onPressed: _login,
            ),
            const SizedBox(height: 12),

            // 공통 텍스트 버튼
            CustomTextButton(
              text: '계정이 없으신가요? 회원가입',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}