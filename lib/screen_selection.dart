import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screen_fruit_dashboard.dart';
import 'api_config.dart';
import 'app_theme.dart';

// =============================================================================
// [Screen 1] 과일 선택 & 슬라이더 방식 로봇 제어 화면
// =============================================================================
class FruitSelectionScreen extends StatefulWidget {
  //이전 화면(로그인)에서 전달받는 전달인자(파라미터)
  final String currentUserId;       // 현재 로그인한 사용자ID
  final String currentUserName;     // 현재 로그인한 사용자 이름

  const FruitSelectionScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<FruitSelectionScreen> createState() => _FruitSelectionScreenState();
}

class _FruitSelectionScreenState extends State<FruitSelectionScreen> {
  //[상태 변수정의]
  String currentRobotId = 'R001';  //제어할 대상 로봇 식별 ID
  String currentZoneId = 'zone01';    //제어할 대상 구역 식별 ID

  // 화면에 띄울 과일 정보 목록 (이름, 아이콘, 백엔드 전송용 과일코드)
  final List<Map<String, String>> fruits = [
    {'name': '딸기', 'icon': '🍓', 'code': 'strawberry'},
    {'name': '사과', 'icon': '🍎', 'code': 'apple'},
    {'name': '포도', 'icon': '🍇', 'code': 'grape'},
    {'name': '복숭아', 'icon': '🍑', 'code': 'peach'},
  ];

  // 슬라이더 상태 값 (0.0: 정지 상태, 1.0: 순찰 동작 상태)
  double _sliderValue = 0.0;
  //중복 신호 방지를 위한 이전 전송 명령 상태 기록 변수
  String _lastSentCommand = 'stop';

  // [네트워크 API 통신함수]
  // 기능> 백엔드 서버로 로봇 제어 명령(stop,start_patrol,return_home) 전송(REST POST)
  // 파라미터> command: 로봇에게 보낼 명령 문자열
  Future<void> _sendCommandToRobot(String command) async {
    try {
      final url = Uri.parse(ApiConfig.robotCommandUrl);

      final Map<String, dynamic> requestBody = {
        'user_id': widget.currentUserId,
        'robot_id': currentRobotId,
        'command': command,
        'zone_id': currentZoneId,
      };

      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 통신 실패: $e')),
      );
    }
  }

  // [슬라이더 조작 및 텍스트 반환 헬퍼 함수]
  //기능>> 슬라이더 이동 완료 후 값을 상태에 반영하고 백엔드로 해당 명령 전송
  //파라미터>> value: 슬라이더의 최종 위치 값(0.0또는 1.0)
  void _sendSingleCommandForValue(double targetValue) {
    String newCommand = (targetValue == 1.0) ? 'start_patrol' : 'stop';

    //기존 명령과 다를 때만 (실제 상태가 전환되었을 때만) 단 한 번 신호 전송
    if (_lastSentCommand != newCommand) {
      _lastSentCommand = newCommand;   //마지막 전송 상태 갱신
      _sendCommandToRobot(newCommand); //백엔드로 신호 1회 전송
    }
  }

  // [UI 레이아웃 빌드 메서드]
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('농장 과일 선택 & 제어'),  //상단 앱바 제목
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //전체 화면 바깥 여백 16px
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, //자식 위젯 가로 폭 꽉 채우기
          children: [ // 상단 사용자 프로필 요약 카드 영역
            Card(
              elevation: 2, //카드 그림자 높이
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '반갑습니다, ${widget.currentUserName}님! (${widget.currentUserId})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20), //위아래 간격 20px

            // 중앙 과일 선택 그리드 영역
            const Text(
              '🍓 모니터링할 과일을 선택하세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true, //자식 요소 높이 합만큼만 그리도 세로 높이 차지
              physics: const NeverScrollableScrollPhysics(), //그리드 자체 내부 스크롤 비활성화
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //2열 격자 배치
                childAspectRatio: 1.0, //가로/세로 비육
                crossAxisSpacing: 10, //아이템 간 가로 간격 10px
                mainAxisSpacing: 6,   //아이템 간 세로 간격 6px
              ),
              itemCount: fruits.length,     //생성할 그리드 아이템 총 개수 (4개)
              itemBuilder: (context, index) {  //index(0~3)에 따라 그리드 아이템 반복 생성
                final fruit = fruits[index];   // 현재 순번의 과일 정보 맵 추출
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg,
                    foregroundColor: AppColors.buttonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),  // 모서리 둥글기 12px
                    ),
                  ),
                  onPressed: () {
                    // 해당 과일 클릭 시 해당 과일 전용 대시보드 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FruitDashboardScreen(
                          currentUserId: widget.currentUserId,
                          currentUserName: widget.currentUserName,
                          selectedFruitName: fruit['name']!,
                          selectedFruitIcon: fruit['icon']!,
                          selectedFruitCode: fruit['code']!,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, //내용물 중앙 정렬
                    children: [
                      Text(fruit['icon']!, style: const TextStyle(fontSize: 36)), // 과일 이모지
                      const SizedBox(width: 8),
                      Text(
                        fruit['name']!, // 과일 이름
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),

            // 하단 슬라이더& 귀환 버튼 로봇 제어 패널
            Card(
              color: Colors.red.shade50,  //패널 연분홍 배경색
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '🤖 로봇 제어 패널',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        //왼쪽영역 5/6 비율을 차지하는 두꺼운 슬라이더 제어부
                        Expanded(
                          flex:6,  // Row 내부 공간 비율 (4)
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 28.0,  //슬라이더트랙막대두께
                                  activeTrackColor: AppColors.robotPanelBg, //비어있는 트랙 색상
                                  thumbColor: AppColors.sliderThumb,   //손잡이(thumb) 색상
                                  overlayColor: AppColors.sliderActive.withOpacity(0.2), //터치 시 번지는 효과 색상
                                  showValueIndicator: ShowValueIndicator.never,  //팝업 툴팁(수치/라벨 표시)을 완전히 비활성화
                                  valueIndicatorShape: const EmptySliderLabelShape(),
                                  thumbShape: TextSliderThumbShape(
                                    value: _sliderValue,
                                    thumbRadius: 22.0,
                                  ),
                                ),
                              child: Slider(
                                value: _sliderValue,  //(현재 슬라이더 가리킴 값 (0.0 ~ 1.0)
                                min: 0.0,             //슬라이더 최소값
                                max: 1.0,             //슬라이더 최대값
                                // 드래그 중에는 UI 위치만 업데이트하고, 신호는 절대 보내지 않음
                                onChanged: (value) {
                                  setState(() {
                                    _sliderValue = value;
                                  });
                                },
                                // 손가락을 뗏을 때 nearest target(0.0 또는 1.0)으로 스르륵 스냅 애니메이션
                                  onChangeEnd: (value) async {
                                  //0.5 미만이면 0.0(정지), 이상이면 1.0(동작)을 타겟으로 설정
                                  double targetValue = value >=0.5 ? 1.0 : 0.0;
                                  int steps = 50;               //애니메이션 프레잌 단계수
                                  double startValue = _sliderValue; //드래그 완료 시점 시작 값
                                  double diff = targetValue - startValue; //이동할 총 거릿값

                                  // 15ms 마다 조금씩 슬라이더  변경하여 부드러운 스냅 모션 구현
                                  for(int i = 1; i <= steps; i++ ) {
                                    await Future.delayed(const Duration(milliseconds: 15));
                                    if(!mounted) return;
                                    setState(() {
                                      _sliderValue = startValue + (diff*(i/steps));
                                    });
                                  }

                                  //위치 지정 및 애니메이션 종료 후 최종 수치 확정
                                    setState(() {
                                      _sliderValue = targetValue;
                                    });
                                  // 전환이 완전히 끝난 후 단 한 번만 백엔드로 명령 전송!
                                   _sendSingleCommandForValue(targetValue);
                                },
                               ),
                              ),
                              const SizedBox(height:6),
                              // 슬라이더 양 끝 '정지/동작' 안내 문구
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal:16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, //양 끝으로 배치
                                  children: [
                                    Text('⏹️ 정지', style: TextStyle(fontSize: 12)),
                                    Text('▶️ 동작', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ),
                        const SizedBox(width: 8),

                        // 오른쪽 영역 5/1 비율을 차지하는 독립 원터치 귀환 버튼
                        Expanded(
                          flex: 1,  //Row 내부 공간 비율(1)
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0), //버튼 세로 여백
                              backgroundColor: Colors.white,      //버튼 배경색 (흰색)
                              foregroundColor: AppColors.primary,  //버튼 텍스트/아이콘 색상
                              side: const BorderSide(color: AppColors.primary),  // 테두리 선 색상
                            ),
                            //클릭 시 즉시 백엔드에 'return_home' 명령 전송
                            onPressed: () => _sendCommandToRobot('return_home'),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home, size: 20),
                                SizedBox(height: 4),
                                Text(
                                  '귀환',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

//  슬라이더 조작 핸들(원형 버튼) 내부에 위치 수치(value)에 맞춰
// '정지' 또는 '동작' 글자와 배경 색상을 직접 렌더링하도록 새로 추가된 커스텀 클래스
class TextSliderThumbShape extends SliderComponentShape {
  final double value;
  final double thumbRadius;

  const TextSliderThumbShape({
    required this.value,
    this.thumbRadius = 20.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    // 슬라이더 수치에 따라 (0.5 이상이면 동작, 미만이면 정지)
    final isDriving = value >= 0.5;
    final String text = isDriving ? '동작' : '정지';
    final Color bgColor = isDriving ? AppColors.sliderActive : Colors.white;
    final Color textColor = isDriving ? Colors.white : Colors.black;

    // 1. 원형 핸들 배경 및 테두리 그리기
    final Paint fillPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = AppColors.sliderActive
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);

    // 2. 핸들 정중앙에 '정지' / '동작' 글자 그리기
    final TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      text: text,
    );

    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout();
    final Offset textOffset = Offset(
      center.dx - (tp.width / 2),
      center.dy - (tp.height / 2),
    );

    tp.paint(canvas, textOffset);
  }
}

// 💡 슬라이더 팝업 말풍선을 아예 그리지 않도록 무력화하는 커스텀 클래스
class EmptySliderLabelShape extends SliderComponentShape {
  const EmptySliderLabelShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow, // 👈 [핵심] size가 아니라 sizeWithOverflow로 지정
      }) {
    // 말풍선을 그리지 않고 빈 상태로 유지
  }
}