// lib/screens/screen_selection.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/service_crop_data.dart';
import '../models/app_models.dart';
import '../providers/auth_provider.dart';
import 'screen_fruit_dashboard.dart';
import 'screen_settings.dart';
import '../core/app_theme.dart';
import '../widgets/custom_slider_thumb.dart';
import '../widgets/app_widgets.dart';
import 'screen_robot_history.dart';
import '../controllers/controller_robot.dart';


class FruitSelectionScreen extends StatefulWidget {
  const FruitSelectionScreen({super.key});

  @override
  State<FruitSelectionScreen> createState() => _FruitSelectionScreenState();
}

class _FruitSelectionScreenState extends State<FruitSelectionScreen> with SingleTickerProviderStateMixin {
  late RobotController _robotController;
  List<CropModel> fruits = [];
  bool _isLoadingCrops = true;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
    _loadCrops();
    final userId = context.read<AuthProvider>().currentUser?.userId ?? '';
    _robotController = RobotController(userId: userId, robotId: 'R001');
    });
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  Future<void> _loadCrops() async {
    final userId = context.read<AuthProvider>().currentUser?.userId ?? '';
    final mergedData = await CropDataService.getMergedCropData(userId);
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
    final updatedFruits = await Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(currentFruits: fruits)));
    if (updatedFruits != null && updatedFruits is List<CropModel>) {
      setState(() => fruits = updatedFruits);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userId = user?.userId ?? '';
    final userName = user?.name ?? '사용자';

    return EcoGlassScaffold(
      title: const Text('농장 과일 선택 & 제어'),
      actions: [
        IconButton(icon: const Icon(Icons.settings_rounded), onPressed: _openSettings),
      ],
      builder: (context, topPadding, bottomPadding) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('반갑습니다, $userName님! 🌱', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(' 모니터링할 과일을 선택하세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_isLoadingCrops)
                const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // 스크롤은 부모(SingleChildScrollView)가 담당
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: fruits.length,
                  itemBuilder: (context, index) {
                    final fruit = fruits[index];
                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBg, foregroundColor: AppColors.buttonText, elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(24), topRight: Radius.circular(8), bottomLeft: Radius.circular(8))),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => FruitDashboardScreen(
                                currentUserId: userId,
                                currentUserName: userName,
                                  selectedFruitName: fruit.name,
                                  selectedFruitIcon: fruit.icon,
                                  selectedFruitCode: fruit.cropId,
                              )
                          ));
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(fruit.icon, style: const TextStyle(fontSize: 40)),
                              const SizedBox(width: 8),
                              Text(fruit.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                    );
                  },
                ),
              const SizedBox(height: 16),

              // 🌟 [오버플로우 해결 2] 하단 패널을 Expanded에서 해제하여 화면 스크롤 시 자연스럽게 아래에 위치하도록 함
              ListenableBuilder(
                  listenable: _robotController,
                  builder: (context, child) {
                    return Card(
                      color: AppColors.robotPanelBg, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 🌟 [오버플로우 해결 3] 가로 폭이 좁을 때 텍스트가 줄어들도록 Flexible + FittedBox 적용
                                const Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(children: [
                                      Icon(Icons.smart_toy_rounded, color: AppColors.primary),
                                      SizedBox(width:8),
                                      Text('로봇 제어 패널', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.buttonText)),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), side: const BorderSide(color: AppColors.primary, width: 1.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RobotHistoryScreen(currentUserId: userId))),
                                        icon: const Icon(Icons.history_rounded, size: 18),
                                        label: const Text('기록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.linkText, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), side: const BorderSide(color: AppColors.linkText, width: 1.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                        onPressed: _robotController.isReturningHome ? null : _robotController.sendReturnCommand,
                                        icon: _robotController.isReturningHome
                                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.linkText))
                                            : const Icon(Icons.home_rounded, size: 18),
                                        label: Text(_robotController.isReturningHome ? '복귀 중...' : '귀환', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 🌟 [오버플로우 해결 5] 슬라이더에 Expanded 대신 충분한 고정 높이(100)를 부여
                            SizedBox(
                              height: 100,
                              child: AnimatedBuilder(
                                  animation: _waveController,
                                  builder: (context, child) {
                                    return SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 60.0, overlayShape: SliderComponentShape.noOverlay, showValueIndicator: ShowValueIndicator.never,
                                        trackShape: StreamFlowTrackShape(waveAnimation: _waveController),
                                        thumbShape: StreamPebbleThumbShape(value: _robotController.sliderValue, thumbRadius: 24.0),
                                      ),
                                      child: Slider(
                                        value: _robotController.sliderValue, min: 0.0, max: 1.0,
                                        onChanged: (value) => _robotController.updateSliderDragging(value),
                                        onChangeEnd: (value) async {
                                          double targetValue = value >= 0.5 ? 1.0 : 0.0;
                                          int steps = 40; double startValue = _robotController.sliderValue; double diff = targetValue - startValue;
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

                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.circle, color: Colors.green, size: 16),
                                  const SizedBox(width: 8),
                                  const Text('현재 위치: ', style: TextStyle(fontSize: 14, color: AppColors.inputLabel, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  Text(_robotController.currentZone.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ],
          ),
        );
      },
    );
  }
}