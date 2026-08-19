// lib/screens/tabs/tab_farm_monitor.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/app_models.dart';
import '../../core/app_theme.dart';
import '../../providers/environment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../screen_fruit_dashboard.dart';

class TabFarmMonitor extends StatelessWidget {
  const TabFarmMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = kToolbarHeight + MediaQuery.of(context).padding.top + 16.0;

    final authProvider = context.watch<AuthProvider>();
    final cropProvider = context.watch<CropProvider>();

    final userId = authProvider.currentUser?.userId ?? '';
    final userName = authProvider.currentUser?.name ?? '사용자';
    final fruits = cropProvider.crops;
    final isLoadingCrops = cropProvider.isLoading;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 환영 카드
          Card(
            color: Colors.white, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('반갑습니다, $userName님! 🌱', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),

          // 농장 실시간 온습도 차트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📊 농장 실시간 온습도', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: const [
                  Icon(Icons.circle, size: 10, color: AppColors.chartTemp), SizedBox(width: 4), Text('온도', style: TextStyle(fontSize: 12)), SizedBox(width: 12),
                  Icon(Icons.circle, size: 10, color: AppColors.chartHumid), SizedBox(width: 4), Text('습도', style: TextStyle(fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Consumer<EnvironmentProvider>(
              builder: (context, envProvider, child) {
                if (envProvider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                if (envProvider.tempSpots.isEmpty || envProvider.humidSpots.isEmpty) {
                  return const Center(child: Text('조회된 온습도 데이터가 없습니다.', style: TextStyle(color: Colors.grey)));
                }

                return LineChart(
                  LineChartData(
                    lineTouchData: const LineTouchData(enabled: false),
                    minY: 0, maxY: 100,
                    minX: envProvider.tempSpots.first.x, maxX: envProvider.tempSpots.last.x,
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
                      LineChartBarData(spots: envProvider.tempSpots, isCurved: true, color: AppColors.chartTemp, barWidth: 3, dotData: const FlDotData(show: true)),
                      LineChartBarData(spots: envProvider.humidSpots, isCurved: true, color: AppColors.chartHumid, barWidth: 3, dotData: const FlDotData(show: false)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // 작물 그리드
          const Text('작물별 현황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (isLoadingCrops)
            const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: fruits.length,
              itemBuilder: (context, index) {
                final fruit = fruits[index];
                return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBg, foregroundColor: AppColors.buttonText, elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(24), topRight: Radius.circular(8), bottomLeft: Radius.circular(8))),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => FruitDashboardScreen(
                          currentUserId: userId,
                          currentUserName: userName,
                          selectedFruitName: fruit.name,
                          selectedFruitIcon: fruit.icon,
                          selectedFruitCode: fruit.cropId,
                        )
                    )),
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
        ],
      ),
    );
  }
}