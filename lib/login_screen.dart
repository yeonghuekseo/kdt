import 'dart:convert'; //JSON 데이터 decode/encode를 위한 DART 표준 라이브러리
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'signup_screen.dart';
import 'screen_selection.dart';
import 'api_config.dart';
import 'app_theme.dart';   // 공통 테마 import
import 'app_widgets.dart'; // 공통 버튼 & 입력창 컴포넌트 import

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

  bool isLoading = false; //로그인 요청 진행 여부 상태 (true: 로딩 중,false: 대기 중)

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

    try {
      // ApiConfig에 정의된 로그인 API 문자열 URL을 Uri 객체로 변환
      final url = Uri.parse(ApiConfig.loginUrl);

      //3.HTTP POST요청: 서버로 ID/PW 전달 (await로 통신 완료 시까지 대기)
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // 서버에 전송 데이터가 JSON임을 명시
        body: jsonEncode({    //Dart Map 객체를 JSON 문자열로 변환
          'user_id': userId,
          'password': password,
        }),
      );

      // 응답 헤더를 체크하여 서버가 JSON 형태의 데이터로 응답했는지 확인
      final isJson = response.headers['content-type']?.contains('application/json') ?? false;

      // 응답 형태가 JSON인 경우
      if (isJson) {
        // 서버 응답 바디(JSON 문자열)를 Dart Map 객체로 변환
        final responseData = jsonDecode(response.body);

        // HTTP 상태코드가 200(성공)인 경우
        if (response.statusCode == 200) {
          // 서버 응답 데이터에서 사용자 정보 추출
          final String loggedInUserId = responseData['data']['user_id'];
          final String loggedInName = responseData['data']['name'];

          // 위젯이 화면 트리에 여전히 존재(mounted)하는지 확인 (비동기 처리 후 안전한 UI변경을 위함)
          if (!mounted) return;

          //로그인 성공 스낵바 안내
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ ${responseData['message']}')),
          );

          // 메인 대시보드로 이동하며 사용자 정보 전달 (이전 로그인 화면은 Navigator에서 제거)
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
          //HTTP 응답이 성공(200)이 아닌 경우 (예: 로그인 실패 400/401 등)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${responseData['message']}')),
          );
        }
      }
    } catch (e) {
      //네트워크 에러 또는 기타 예외 발생 시 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 서버 연결 실패: $e')),
      );
    } finally {
      // 성공/실패 여부와 상관없이 통신이 끝나면 로딩상태 해제
      setState(() => isLoading = false);
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
            // [수정] 공통 ID 입력창
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

            // [수정] 공통 텍스트 버튼
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