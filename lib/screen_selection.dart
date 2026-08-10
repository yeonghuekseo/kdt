// lib/screen_selection.dart
import 'package:flutter/material.dart';
import 'screen_fruit_dashboard.dart';
import 'app_theme.dart';
import 'robot_control_service.dart';
import 'custom_slider_thumb.dart'; // 💡 새롭게 만든 시냇물 트랙과 조약돌 썸을 가져옵니다.

class FruitSelectionScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const FruitSelectionScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  // 💡 [핵심 원리] 물결 애니메이션을 무한 반복시키기 위해 SingleTickerProviderStateMixin을 추가합니다.
  State<FruitSelectionScreen> createState() => _FruitSelectionScreenState();
}

class _FruitSelectionScreenState extends State<FruitSelectionScreen> with SingleTickerProviderStateMixin {
  final RobotControlService _robotService = RobotControlService();

  String currentTargetZone = 'zone01';
  final List<String> availableZones = ['zone01', 'zone02', 'zone03'];

  final List<Map<String, String>> fruits = [
    {'name': '딸기', 'icon': '🍓', 'code': 'strawberry'},
    {'name': '사과', 'icon': '🍎', 'code': 'apple'},
    {'name': '포도', 'icon': '🍇', 'code': 'grape'},
    {'name': '복숭아', 'icon': '🍑', 'code': 'peach'},
  ];

  double _sliderValue = 0.0;

  // 💡 [신규 변수] 물결이 계속해서 흐르도록 시간을 세어줄 애니메이션 타이머(컨트롤러)입니다.
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // 💡 2초 동안 0.0 -> 1.0으로 값이 변하는 타이머를 만들고, 영원히 반복(repeat)시킵니다.
    // 이 타이머 덕분에 시냇물 파동이 멈추지 않고 흘러갑니다.
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    // 💡 화면이 꺼지면 메모리 낭비를 막기 위해 물결 타이머도 반드시 부숴줍니다.
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('농장 과일 선택 & 제어')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----- 1. 상단 프로필 및 과일 선택 영역 (고정 크기) -----
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '반갑습니다, ${widget.currentUserName}님! 🌱',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(' 모니터링할 과일을 선택하세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: fruits.length,
              itemBuilder: (context, index) {
                final fruit = fruits[index];
                return ElevatedButton(
                  // ... 과일 버튼 설정 유지 ...
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg, foregroundColor: AppColors.buttonText, elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(24), topRight: Radius.circular(8), bottomLeft: Radius.circular(8),)),
                  ),
                  onPressed: () {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(fruit['icon']!, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 8),
                      Text(fruit['name']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16), // 그리드와 하단 패널 사이의 여백

            // =================================================================
            // 💡 [수정 이유 및 원리: 하단 공간을 지배하는 초대형 제어 패널]
            // Expanded를 적용하여, 기기 화면이 길든 짧든 남는 아래쪽 공간을
            // 이 카드가 100% 꽉 채우도록(중간으로 채워넣기) 강제합니다.
            // =================================================================
            Expanded(
              child: Card(
                color: AppColors.robotPanelBg,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0), // 상하 여백 넉넉히
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- 패널 1층: 제목과 귀환 버튼 ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                              children: [
                                Icon(Icons.smart_toy_rounded, color: AppColors.primary),
                                SizedBox(width:8),
                                Text('로봇 제어 패널', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.buttonText)),
                              ]
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, foregroundColor: AppColors.linkText, elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              side: const BorderSide(color: AppColors.linkText, width: 1.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => _robotService.sendCommandToRobot('return_home', currentTargetZone, onError: (errorMsg) {}),
                            icon: const Icon(Icons.home, size: 18),
                            label: const Text('귀환', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),

                      // --- 패널 2층: 광활하게 펼쳐지는 두꺼운 시냇물 슬라이더 ---
                      // 💡 또 한 번 Expanded를 써서, 제목과 구역 선택칸을 뺀 나머지 모든 공간을 슬라이더가 다 먹게 합니다!
                      Expanded(
                        // 💡 [핵심 원리] AnimatedBuilder: 물결 애니메이션 타이머가 틱(Tick)할 때마다 슬라이더를 실시간으로 다시 그려냅니다. (이게 없으면 시냇물이 멈춰있습니다)
                        child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  // 🛠️ [파라미터 조정 가이드] 트랙 두께를 기존 28.0에서 무려 60.0으로 2배 이상 키워 두껍고 시원시원하게 만들었습니다!
                                  trackHeight: 60.0,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  showValueIndicator: ShowValueIndicator.never,

                                  // 💡 [교체] 방금 만든 커스텀 시냇물 트랙을 끼워 넣고, 타이머(_waveController)를 건네줍니다.
                                  trackShape: StreamFlowTrackShape(waveAnimation: _waveController),

                                  // 💡 [교체] 조약돌 썸은 유지하되 사이즈를 조금 더 키웁니다.
                                  thumbShape: StreamPebbleThumbShape(
                                    value: _sliderValue,
                                    thumbRadius: 24.0, // 두꺼워진 트랙에 맞게 손잡이도 조금 더 키웠습니다.
                                  ),
                                ),
                                child: Slider(
                                  value: _sliderValue,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (value) {
                                    setState(() { _sliderValue = value; });
                                  },
                                  onChangeEnd: (value) async {
                                    // 스냅 애니메이션
                                    double targetValue = value >= 0.5 ? 1.0 : 0.0;
                                    int steps = 40;
                                    double startValue = _sliderValue;
                                    double diff = targetValue - startValue;
                                    for(int i = 1; i <= steps; i++ ) {
                                      await Future.delayed(const Duration(milliseconds: 12));
                                      if(!mounted) return;
                                      setState(() { _sliderValue = startValue + (diff * (i / steps)); });
                                    }
                                    setState(() { _sliderValue = targetValue; });
                                    _robotService.sendSingleCommandForValue(targetValue, currentTargetZone, onError: (errorMsg) {});
                                  },
                                ),
                              );
                            }
                        ),
                      ),

                      // --- 패널 지하 1층: 구역(Zone) 선택 영역 ---
                      // 💡 [수정 이유] 요청에 따라 "목표 구역 띄워주는 화면을 패널 밑에 넣어서" 배치했습니다.
                      // 상단에 있던 메뉴가 카드 맨 밑바닥으로 이동하여 안정감을 줍니다.
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16), // 둥근 흰색 박스로 감싸서 디자인 완성도 업!
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // 텍스트를 중앙 정렬합니다.
                          children: [
                            const Text('현재 이동 목표 구역: ', style: TextStyle(fontSize: 14, color: AppColors.inputLabel, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: currentTargetZone,
                              isDense: true,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.linkText),
                              items: availableZones.map((String zone) {
                                return DropdownMenuItem<String>(
                                  value: zone,
                                  child: Text(zone),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) setState(() { currentTargetZone = newValue; });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}