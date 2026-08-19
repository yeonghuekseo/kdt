// lib/screens/screen_fruit_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../controllers/controller_fruit_dashboard.dart';
import '../providers/alert_provider.dart';
import 'screen_disease_alert_history.dart';

class FruitDashboardScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String selectedFruitName;
  final String selectedFruitIcon;
  final String selectedFruitCode;

  const FruitDashboardScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.selectedFruitName,
    required this.selectedFruitIcon,
    required this.selectedFruitCode
  });

  @override
  State<FruitDashboardScreen> createState() => _FruitDashboardScreenState();
}

class _FruitDashboardScreenState extends State<FruitDashboardScreen> {
  late FruitDashboardController _dashboardController;

  @override
  void initState() {
    super.initState();
    _dashboardController = FruitDashboardController(
      userId: widget.currentUserId,
      fruitCode: widget.selectedFruitCode,
    );
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    super.dispose();
  }

  void _goToAlertHistoryScreen(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => ScreenDiseaseAlertHistory(currentUserId: widget.currentUserId)
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final isMqttConnected = alertProvider.isConnected;
    final alertCount = alertProvider.alertLogs.length;

    return EcoGlassScaffold(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('${widget.selectedFruitIcon} ${widget.selectedFruitName} 대시보드'),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: isMqttConnected ? Colors.green : Colors.red),
              const SizedBox(width: 6),
                  Text(isMqttConnected ? 'MQTT 연결됨' : '연결 끊김', style: const TextStyle(fontSize: 12)),
                ],
          ),
        )
      ],
      builder: (context, topPadding, bottomPadding) {
        return Padding(
          padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppColors.alertCardBg,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Flexible(flex: 1, child: FittedBox(fit: BoxFit.scaleDown, child: Text(widget.selectedFruitIcon, style: const TextStyle(fontSize: 32)))),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('${widget.selectedFruitName} 실시간 환경 모니터링', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('사용자: ${widget.currentUserName}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ListenableBuilder(
                        listenable: _dashboardController,
                        builder: (context, _) {
                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              side: BorderSide(color: Colors.red.shade300, width: 1.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => _goToAlertHistoryScreen(context),
                            icon: const Icon(Icons.warning_amber_rounded, size: 18),
                            label: Text('$alertCount건', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('📊 생육 비율 집계', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: const [
                      Icon(Icons.square, size: 12, color: Colors.green), SizedBox(width: 4), Text('미숙', style: TextStyle(fontSize: 12)), SizedBox(width: 8),
                      Icon(Icons.square, size: 12, color: Colors.redAccent), SizedBox(width: 4), Text('적숙', style: TextStyle(fontSize: 12)), SizedBox(width: 8),
                      Icon(Icons.square, size: 12, color: Colors.purple), SizedBox(width: 4), Text('과숙', style: TextStyle(fontSize: 12)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ListenableBuilder(
                  listenable: _dashboardController,
                  builder: (context, _) {
                    final ripenessList = _dashboardController.ripenessList;
                    if (ripenessList.isEmpty) return const Center(child: Text('집계된 데이터가 없습니다.', style: TextStyle(color: Colors.grey)));

                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 80,
                        barTouchData: BarTouchData(enabled: false),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text('수량(개)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true, reservedSize: 30,
                              getTitlesWidget: (v, m) => v % 20 != 0 ? const SizedBox.shrink() : Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= ripenessList.length) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(ripenessList[index].date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 1))),

                        barGroups: ripenessList.asMap().entries.map((entry) {
                          int index = entry.key;
                          RipenessData data = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(toY: data.unripeCount.toDouble(), color: Colors.green, width: 6, borderRadius: BorderRadius.circular(2)),
                              BarChartRodData(toY: data.ripeCount.toDouble(), color: Colors.redAccent, width: 6, borderRadius: BorderRadius.circular(2)),
                              BarChartRodData(toY: data.overripeCount.toDouble(), color: Colors.purple, width: 6, borderRadius: BorderRadius.circular(2)),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('📸 작물 조회 이력', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // 🌟 수정 부분: 컨트롤러에 없는 inspectionLogs 대신 빈 리스트 처리 또는 추후 구현을 위한 뼈대만 남김
                    final logs = [];
                    if (logs.isEmpty) return const Center(child: Text('조회 이력이 없습니다.', style: TextStyle(color: Colors.grey)));
                    return ListView();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}