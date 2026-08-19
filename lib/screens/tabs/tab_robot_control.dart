// lib/screens/tabs/tab_robot_control.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/robot_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_slider_thumb.dart';
import '../../widgets/robot_path_map.dart'; // 분리된 맵 위젯
import '../screen_robot_history.dart';

class TabRobotControl extends StatefulWidget {
  const TabRobotControl({super.key});

  @override
  State<TabRobotControl> createState() => _TabRobotControlState();
}

class _TabRobotControlState extends State<TabRobotControl> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _snapController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _snapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _snapController.addListener(() {
      if (mounted) {
        context.read<RobotProvider>().updateSliderDragging(_snapController.value);
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = kToolbarHeight + MediaQuery.of(context).padding.top + 16.0;

    final userId = context.watch<AuthProvider>().currentUser?.userId ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 24),
      child: Consumer<RobotProvider>(
        builder: (context, robotProvider, child) {
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
                          fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                          child: Row(children: [
                            Icon(Icons.smart_toy_rounded, color: AppColors.primary), SizedBox(width:8),
                            Text('로봇 제어 패널', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.buttonText)),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown, alignment: Alignment.centerRight,
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
                              onPressed: robotProvider.isReturningHome ? null : () => context.read<RobotProvider>().sendReturnCommand(userId, 'R001'),
                              icon: robotProvider.isReturningHome ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.linkText)) : const Icon(Icons.home_rounded, size: 18),
                              label: Text(robotProvider.isReturningHome ? '복귀 중...' : '귀환', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 분리된 U자 맵 위젯
                  RobotPathMap(currentZone: robotProvider.currentZone),
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
                                _snapController.animateTo(targetValue, curve: Curves.easeOutCubic).then((_) {
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
                  const SizedBox(height: 8),
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
        },
      ),
    );
  }
}