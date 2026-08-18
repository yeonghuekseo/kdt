// lib/screens/screen_selection.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/service_crop_data.dart';
import '../models/app_models.dart';
import '../providers/auth_provider.dart';
import '../providers/robot_provider.dart';
import 'screen_fruit_dashboard.dart';
import 'screen_settings.dart';
import '../core/app_theme.dart';
import '../widgets/custom_slider_thumb.dart';
import '../widgets/app_widgets.dart';
import 'screen_robot_history.dart';



class FruitSelectionScreen extends StatefulWidget {
  const FruitSelectionScreen({super.key});

  @override
  State<FruitSelectionScreen> createState() => _FruitSelectionScreenState();
}

class _FruitSelectionScreenState extends State<FruitSelectionScreen> with TickerProviderStateMixin {
  List<CropModel> fruits = [];
  bool _isLoadingCrops = true;
  late AnimationController _waveController;
  late AnimationController _snapController;
  // 🌟 메인 화면용 임시 온습도 데이터 (추후 API 연동 필요)
  final List<FlSpot> _dummyTempSpots = const [FlSpot(0, 22), FlSpot(1, 24), FlSpot(2, 23), FlSpot(3, 26), FlSpot(4, 25)];
  final List<FlSpot> _dummyHumidSpots = const [FlSpot(0, 60), FlSpot(1, 62), FlSpot(2, 58), FlSpot(3, 65), FlSpot(4, 63)];


  @override
  void initState() {
    super.initState();
    _loadCrops();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _snapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _snapController.addListener(() {
      if (mounted) {
        context.read<RobotProvider>().updateSliderDragging(_snapController.value);
      }
    });
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
    _snapController.dispose();
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
              // 🌟 [추가됨] 대시보드에서 옮겨온 농장 전체 온습도 차트 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('📊 농장 실시간 온습도', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: const [
                      Icon(Icons.circle, size: 10, color: AppColors.chartTemp),
                      SizedBox(width: 4), Text('온도', style: TextStyle(fontSize: 12)), SizedBox(width: 12),
                      Icon(Icons.circle, size: 10, color: AppColors.chartHumid),
                      SizedBox(width: 4), Text('습도', style: TextStyle(fontSize: 12)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180, // 높이를 살짝 줄여 화면 밸런스 유지
                child: LineChart(
                  LineChartData(
                    lineTouchData: const LineTouchData(enabled: false),
                    minY: 0, maxY: 100, minX: 0, maxX: 4,
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        axisNameSize: 20,
                        sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => v % 20 != 0 ? const SizedBox.shrink() : Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey))),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                    lineBarsData: [
                      LineChartBarData(spots: _dummyTempSpots, isCurved: true, color: AppColors.chartTemp, barWidth: 3, dotData: const FlDotData(show: true)),
                      LineChartBarData(spots: _dummyHumidSpots, isCurved: true, color: AppColors.chartHumid, barWidth: 3, dotData: const FlDotData(show: false)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('작물별 현황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

              Consumer<RobotProvider>(
                  builder: (context,robotProvider, child) {
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
                                        onPressed: robotProvider.isReturningHome
                                            ? null
                                            : () => context.read<RobotProvider>().sendReturnCommand(userId, 'R001'),
                                        icon: robotProvider.isReturningHome
                                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.linkText))
                                            : const Icon(Icons.home_rounded, size: 18),
                                        label: Text(robotProvider.isReturningHome ? '복귀 중...' : '귀환', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              height: 100,
                              child: AnimatedBuilder(
                                  animation: _waveController,
                                  builder: (context, child) {
                                    return SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 60.0, overlayShape: SliderComponentShape.noOverlay, showValueIndicator: ShowValueIndicator.never,
                                        trackShape: StreamFlowTrackShape(waveAnimation: _waveController),
                                        thumbShape: StreamPebbleThumbShape(value: robotProvider.sliderValue, thumbRadius: 24.0),
                                      ),
                                      child: Slider(
                                        value: robotProvider.sliderValue, min: 0.0, max: 1.0,
                                        onChanged: (value) => context.read<RobotProvider>().updateSliderDragging(value),
                                        onChangeEnd: (value) {
                                          double targetValue = value >= 0.5 ? 1.0 : 0.0;
                                          _snapController.value = value;
                                          _snapController.animateTo(
                                            targetValue,
                                            curve: Curves.easeOutCubic,
                                          ).then((_) {
                                            if (mounted) {
                                              context.read<RobotProvider>().updateSliderEnd(targetValue, userId, 'R001');
                                            }
                                          });
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
                                  Text(robotProvider.currentZone.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
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