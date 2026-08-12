// lib/screen_fruit_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';
import '../controllers/controller_fruit_dashboard.dart';

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
    required this.selectedFruitCode,
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
      fruitName: widget.selectedFruitName,
    );
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.alertCardBg,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(widget.selectedFruitIcon, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${widget.selectedFruitName} 실시간 환경 모니터링',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '사용자: ${widget.currentUserName} (${widget.currentUserId})',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
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
                    Icon(Icons.circle, size: 10, color: Colors.red),
                    SizedBox(width: 4),
                    Text('온도', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 12),
                    Icon(Icons.circle, size: 10, color: Colors.blue),
                    SizedBox(width: 4),
                    Text('습도', style: TextStyle(fontSize: 12)),
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
                  if (_dashboardController.tempSpots.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return LineChart(
                    LineChartData(
                      lineTouchData: const LineTouchData(enabled: false),
                      minY: 0,
                      maxY: 100,
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text('온도(℃)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                          axisNameSize: 20,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            getTitlesWidget: (value, meta) {
                              if (value % 20 != 0) return const SizedBox.shrink();
                              return Text('${value.toInt()}', style: const TextStyle(fontSize: 11, color: Colors.red));
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          axisNameWidget: const Text('습도(%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                          axisNameSize: 20,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            getTitlesWidget: (value, meta) {
                              if (value % 20 != 0) return const SizedBox.shrink();
                              return Text('${value.toInt()}', style: const TextStyle(fontSize: 11, color: Colors.blue));
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _dashboardController.tempSpots,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: _dashboardController.humiditySpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: const FlDotData(show: false), // 🌟 dotCode -> dotData로 수정 및 불필요한 as 캐스팅 제거
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🚨 AI 비전 진단 알림 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ListenableBuilder(
                  listenable: _dashboardController,
                  builder: (context, _) => Text('${_dashboardController.alertLogs.length}건 발생', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListenableBuilder(
                listenable: _dashboardController,
                builder: (context, _) {
                  final logs = _dashboardController.alertLogs;
                  if (logs.isEmpty) {
                    return Center(child: Text('이상 감지 내역이 없습니다.', style: TextStyle(color: Colors.grey.shade600)));
                  }
                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final alert = logs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: alert['image_url'] != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              alert['image_url'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                              : const Icon(Icons.warning, color: Colors.red),
                          title: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              alert['message'] ?? '진단결과',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
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
      ),
    );
  }
}