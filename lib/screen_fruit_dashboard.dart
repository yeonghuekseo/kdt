import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_config.dart';
import 'app_theme.dart';
import 'disease_alert_dialog.dart';

// =============================================================================
// [Screen 2] 선택 과일 전용 대시보드 그래프 화면
// =============================================================================
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
  MqttServerClient? client;
  bool isConnected = false;
  List<FlSpot> chartPoints = [];
  int xCounter = 0;

  final List<Map<String, dynamic>> _alertLogs = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initMqtt();
  }

  /// REST GET: 선택 과일 데이터 백엔드 로드
  Future<void> _loadInitialData() async {
    try {
      final url = Uri.parse('${ApiConfig.dashboardLogsUrl}?fruit=${widget.selectedFruitCode}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<FlSpot> loadedSpots = [];

        for (int i = 0; i < data.length; i++) {
          double yValue = (data[i]['temperature'] ?? data[i]['y'] ?? 0.0).toDouble();
          loadedSpots.add(FlSpot(i.toDouble(), yValue));
        }

        setState(() {
          chartPoints = loadedSpots;
          xCounter = loadedSpots.length;
        });
      }
    } catch (e) {
      debugPrint('❌ DB 데이터 로드 실패: $e');
    }
  }

  /// MQTT 통신 연결
  Future<void> _initMqtt() async {
    final String clientId = 'flutter_${widget.currentUserId}_${DateTime.now().millisecondsSinceEpoch}';

    client = MqttServerClient(ApiConfig.serverIp, clientId);
    client!.port = ApiConfig.mqttPort;
    client!.keepAlivePeriod = 20;
    client!.logging(on: false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
      setState(() => isConnected = true);

      final String envTopic = 'ddalgi/env/log/${widget.selectedFruitCode}';
      client!.subscribe(envTopic, MqttQos.atMostOnce);

      final String alertTopic = 'ddalgi/alert/disease/${widget.currentUserId}';
      client!.subscribe(alertTopic, MqttQos.atMostOnce);

      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        final String receivedTopic = c[0].topic;
        final Map<String, dynamic> data = jsonDecode(pt);

        if (receivedTopic == envTopic) {
          _parseAndUpdateGraph(data);
        } else if (receivedTopic == alertTopic) {
          _handleDiseaseAlert(data);
        }
      });
    } catch (e) {
      debugPrint('❌ MQTT 연결 실패: $e');
      client!.disconnect();
      setState(() => isConnected = false);
    }
  }

  void _parseAndUpdateGraph(Map<String, dynamic> data) {
    double value = (data['temperature'] ?? data['y'] ?? 0.0).toDouble();
    setState(() {
      chartPoints.add(FlSpot(xCounter.toDouble(), value));
      xCounter++;
      if (chartPoints.length > 20) chartPoints.removeAt(0);
    });
  }

  // 💡 백엔드 비전 알림 처리 (독립된 팝업 클래스 호출)
  void _handleDiseaseAlert(Map<String, dynamic> alertData) {
    setState(() {
      _alertLogs.insert(0, alertData);
    });

    if (!mounted) return;

    // 분리된 AlertDialog 모듈 실행
    DiseaseAlertDialog.show(
      context,
      alertData: alertData,
      fallbackFruitName: widget.selectedFruitName,
    );
  }

  @override
  void dispose() {
    client?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedFruitIcon} ${widget.selectedFruitName} 대시보드'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.circle, size: 12, color: isConnected ? Colors.green : Colors.red),
                const SizedBox(width: 6),
                Text(isConnected ? 'MQTT 연결됨' : '연결 끊김', style: const TextStyle(fontSize: 12)),
              ],
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
              color: AppColors.alertCardBg,  //테마 배경색 적용
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(widget.selectedFruitIcon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.selectedFruitName} 실시간 환경 모니터링',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '사용자: ${widget.currentUserName} (${widget.currentUserId})',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('📊 실시간 분석결과..', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: chartPoints.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartPoints,
                      isCurved: true,
                      isStrokeCapRound: true,
                      color: AppColors.primary,  //차트선 색상 테마 적용
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🚨 AI 비전 진단 알림 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${_alertLogs.length}건 발생', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _alertLogs.isEmpty
                  ? Center(
                child: Text(
                  '이상 감지 내역이 없습니다.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
                  : ListView.builder(
                itemCount: _alertLogs.length,
                itemBuilder: (context, index) {
                  final alert = _alertLogs[index];
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
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                          : const Icon(Icons.warning, color: Colors.red),
                      title: Text(
                        alert['message'] ?? '진단결과',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text('구역: ${alert['zone'] ?? '-'} | 상태: ${alert['health_status'] ?? '-'}'),
                    ),
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