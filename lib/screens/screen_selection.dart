// lib/screen_selection.dart
import 'package:flutter/material.dart';
import '../services/service_crop_data.dart';
import 'screen_fruit_dashboard.dart';
import 'settings_screen.dart';
import '../core/app_theme.dart';
import '../widgets/custom_slider_thumb.dart';
import 'screen_robot_history.dart';
import '../controllers/controller_robot.dart';

class FruitSelectionScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const FruitSelectionScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<FruitSelectionScreen> createState() => _FruitSelectionScreenState();
}

class _FruitSelectionScreenState extends State<FruitSelectionScreen> with SingleTickerProviderStateMixin {
  late RobotController _robotController;

  List<Map<String, String>> fruits = [];
  bool _isLoadingCrops = true;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _loadCrops();
    _robotController = RobotController(userId: widget.currentUserId, robotId: 'R001');

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  Future<void> _loadCrops() async {
    final mergedData = await CropDataService.getMergedCropData(widget.currentUserId);
    if (!mounted) return;
    setState(() {
      fruits = mergedData;
      _isLoadingCrops = false;
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _robotController.dispose();
    super.dispose();
  }

  Future<void> _openSettings() async {
    final updatedFruits = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(currentFruits: fruits),
      ),
    );

    if (updatedFruits != null && updatedFruits is List<Map<String, String>>) {
      setState(() {
        fruits = updatedFruits;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('농장 과일 선택 & 제어'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: '농장 설정',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            if (_isLoadingCrops)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
            else
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
                              selectedFruitName: fruit['name'] ?? '알 수 없음',
                              selectedFruitIcon: fruit['icon'] ?? '🌱',
                              selectedFruitCode: fruit['crop_id'] ?? fruit['code'] ?? 'unknown',
                            ),
                          ),
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(fruit['icon'] ?? '🌱', style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: 8),
                            Text(fruit['name'] ?? '알 수 없음', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                  );
                },
              ),
            const SizedBox(height: 16),

            Expanded(
              child: ListenableBuilder(
                  listenable: _robotController,
                  builder: (context, child) {
                    return Card(
                      color: AppColors.robotPanelBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        side: const BorderSide(color: AppColors.primary, width: 1.0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RobotHistoryScreen(
                                              currentUserId: widget.currentUserId,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.history, size: 18),
                                      label: const Text('기록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                    const SizedBox(width: 8),

                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white, foregroundColor: AppColors.linkText, elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        side: const BorderSide(color: AppColors.linkText, width: 1.0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: _robotController.isReturningHome ? null : _robotController.sendReturnCommand,
                                      icon: _robotController.isReturningHome
                                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.linkText))
                                          : const Icon(Icons.home, size: 18),
                                      label: Text(_robotController.isReturningHome ? '복귀 중...' : '귀환', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Expanded(
                              child: AnimatedBuilder(
                                  animation: _waveController,
                                  builder: (context, child) {
                                    return SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 60.0,
                                        overlayShape: SliderComponentShape.noOverlay,
                                        showValueIndicator: ShowValueIndicator.never,
                                        trackShape: StreamFlowTrackShape(waveAnimation: _waveController),
                                        thumbShape: StreamPebbleThumbShape(
                                          value: _robotController.sliderValue,
                                          thumbRadius: 24.0,
                                        ),
                                      ),
                                      child: Slider(
                                        value: _robotController.sliderValue,
                                        min: 0.0,
                                        max: 1.0,
                                        onChanged: (value) => _robotController.updateSliderDragging(value),
                                        onChangeEnd: (value) async {
                                          double targetValue = value >= 0.5 ? 1.0 : 0.0;
                                          int steps = 40;
                                          double startValue = _robotController.sliderValue;
                                          double diff = targetValue - startValue;
                                          for(int i = 1; i <= steps; i++ ) {
                                            await Future.delayed(const Duration(milliseconds: 12));
                                            if(!mounted) return;
                                            _robotController.updateSliderDragging(startValue + (diff * (i / steps)));
                                          }
                                          _robotController.updateSliderEnd(targetValue);
                                        },
                                      ),
                                    );
                                  }
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.circle, color: Colors.green, size: 16),
                                  const SizedBox(width: 8),
                                  const Text('현재 위치: ', style: TextStyle(fontSize: 14, color: AppColors.inputLabel, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _robotController.currentZone.toUpperCase(),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}