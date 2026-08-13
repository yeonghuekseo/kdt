// lib/screens/screen_fruit_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../controllers/controller_fruit_dashboard.dart';
import 'screen_disease_alert_history.dart';

class FruitDashboardScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String selectedFruitName;
  final String selectedFruitIcon;
  final String selectedFruitCode;

  const FruitDashboardScreen({super.key, required this.currentUserId, required this.currentUserName, required this.selectedFruitName, required this.selectedFruitIcon, required this.selectedFruitCode});

  @override
  State<FruitDashboardScreen> createState() => _FruitDashboardScreenState();
}

class _FruitDashboardScreenState extends State<FruitDashboardScreen> {
  late FruitDashboardController _dashboardController;

  @override
  void initState() {
    super.initState();
    _dashboardController = FruitDashboardController(userId: widget.currentUserId, fruitName: widget.selectedFruitName);
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    super.dispose();
  }

  void _goToAlertHistoryScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ScreenDiseaseAlertHistory(currentUserId: widget.currentUserId)));
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 [모듈화 적용] 엄청나게 깔끔해진 대시보드 뼈대
    return EcoGlassScaffold(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('${widget.selectedFruitIcon} ${widget.selectedFruitName} 대시보드'),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListenableBuilder(
            listenable: _dashboardController,
            builder: (context, _) {
              bool connected = _dashboardController.isConnected;
              return Row(
                children: [
                  Icon(Icons.circle, size: 12, color: connected ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Text(connected ? 'MQTT 연결됨' : '연결 끊김', style: const TextStyle(fontSize: 12)),
                ],
              );
            },
          ),
        )
      ],
      builder: (context, topPadding, bottomPadding) {
        return Padding(
          // 🌟 모듈에서 넘겨준 자동 계산 패딩 사용
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
                            label: Text('${_dashboardController.alertLogs.length}건', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                  const Text('📊 실시간 온습도 환경 분석', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                height: 220,
                child: ListenableBuilder(
                  listenable: _dashboardController,
                  builder: (context, _) {
                    if (_dashboardController.tempSpots.isEmpty) return const Center(child: CircularProgressIndicator());
                    return LineChart(
                      LineChartData(
                        lineTouchData: const LineTouchData(enabled: false), minY: 0, maxY: 100,
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text('온도(℃)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.chartTemp)),
                            axisNameSize: 20,
                            sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) => v % 20 != 0 ? const SizedBox.shrink() : Text('${v.toInt()}', style: const TextStyle(fontSize: 11, color: AppColors.chartTemp))),
                          ),
                          rightTitles: AxisTitles(
                            axisNameWidget: const Text('습도(%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.chartHumid)),
                            axisNameSize: 20,
                            sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) => v % 20 != 0 ? const SizedBox.shrink() : Text('${v.toInt()}', style: const TextStyle(fontSize: 11, color: AppColors.chartHumid))),
                          ),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                        lineBarsData: [
                          LineChartBarData(spots: _dashboardController.tempSpots, isCurved: true, color: AppColors.chartTemp, barWidth: 3, dotData: const FlDotData(show: true)),
                          LineChartBarData(spots: _dashboardController.humiditySpots, isCurved: true, color: AppColors.chartHumid, barWidth: 3, dotData: const FlDotData(show: false)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('🚨 AI 비전 진단 알림 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListenableBuilder(
                  listenable: _dashboardController,
                  builder: (context, _) {
                    final logs = _dashboardController.alertLogs;
                    if (logs.isEmpty) return const Center(child: Text('이상 감지 내역이 없습니다.', style: TextStyle(color: Colors.grey)));
                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final alert = logs[index];
                        return Card(
                          elevation: 0, color: Colors.white, margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                          child: ListTile(
                            leading: alert['image_url'] != null
                                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(alert['image_url'], width: 50, height: 50, fit: BoxFit.cover))
                                : Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                            ),
                            title: Text(alert['message'] ?? '진단결과', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('구역: ${alert['zone'] ?? '-'} | 상태: ${alert['health_status'] ?? '-'}'),
                          ),
                        );
                      },
                    );
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