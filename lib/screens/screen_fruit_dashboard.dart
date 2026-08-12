import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../widgets/disease_alert_dialog.dart';

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
  List<FlSpot> tempSpots = [];
  List<FlSpot> humiditySpots = [];  //온도와 습도 데이터를 각각 담을 리스트 분리
  int xCounter = 0;

  final List<Map<String, dynamic>> _alertLogs = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();    // 과거 기록 데이터 (REST API) 로드
    _initMqtt();           // 실시간 데이터 (MQTT) 구독 시작
  }

  /// REST GET: 백엔드에서 초기 기록 10개 가져오기
  Future<void> _loadInitialData() async {
    try {
      final url = Uri.parse(ApiConfig.envLogsUrl(widget.currentUserId));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String,dynamic> responseData = jsonDecode(response.body);

        //  백엔드 응답 형식 {"status": "success", "data": [...]} 분석 및 예외 처리
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final List<dynamic> logs = responseData['data'];
          List<FlSpot> loadedTemp = [];
          List<FlSpot> loadedHumid = [];


          for (int i = 0; i < logs.length; i++) {
            //온도 데이터 필드명: 'temperature'
            double tValue = (logs[i]['temperature'] ?? 0.0).toDouble();
            double hValue = (logs[i]['humidity'] ?? 0.0).toDouble();

            loadedTemp.add(FlSpot(i.toDouble(), tValue));
            loadedHumid.add(FlSpot(i.toDouble(), hValue));
          }

          setState(() {
            tempSpots = loadedTemp;
            humiditySpots = loadedHumid;
            xCounter = logs.length;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ 최근 환경 로그 데이터 로드 실패: $e');
    }
  }

  // MQTT 통신 연결 및 수신 핸들러 등록
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

      // 로봇의 실시간 상태/센서 보고 토픽 구독 (3-1)
      const String robotStatusTopic = 'ddalgi/robot/status';
      client!.subscribe(robotStatusTopic, MqttQos.atMostOnce);

      // 병충해 실시간 경고 토픽 구독 (4-1)
      final String alertTopic = ApiConfig.diseaseAlertTopic(widget.currentUserId);
      client!.subscribe(alertTopic, MqttQos.atMostOnce);

      //MQTT 메시지 수신 이벤트 리스너
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        final String receivedTopic = c[0].topic;
        final Map<String, dynamic> data = jsonDecode(pt);

        // 로봇 데이터 수신시 _parseAndUpdateGraph를 호출
        if (receivedTopic == robotStatusTopic) {
          _parseAndUpdateGraph(data);
        }
        //병충해 경고 수신시 알림 팝업 호출
        if (receivedTopic == alertTopic) {
          _handleDiseaseAlert(data);
        }
      });
    } catch (e) {
      debugPrint('❌ MQTT 연결 실패: $e');
      client!.disconnect();
      setState(() => isConnected = false);
    }
  }

  //MQTT로 들어온 실시간 온습도 데이터를 차트에 즉시 추가하는 함수
  void _parseAndUpdateGraph(Map<String, dynamic> data) {
    double tValue = (data['temperature'] ?? 0.0).toDouble();
    double hValue = (data['humidity'] ?? 0.0).toDouble();

    setState(() {
      // 실시간 데이터도 두 개의 리스트에 각각 추가
      tempSpots.add(FlSpot(xCounter.toDouble(), tValue));
      humiditySpots.add(FlSpot(xCounter.toDouble(), hValue));
      xCounter++;

      //차트 그래프가 너무 빽빽해지지 않도록 최근 20개 점만 유지
      if (tempSpots.length > 20) {
        tempSpots.removeAt(0);
        humiditySpots.removeAt(0);
      }
    });
  }

  // 병충해 감지 푸시 백엔드 비전 알림 처리 (독립된 팝업 클래스 호출)
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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('${widget.selectedFruitIcon} ${widget.selectedFruitName} 대시보드'),
          ),
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
                    Flexible(
                      flex: 1,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(widget.selectedFruitIcon, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
            //그래프 범례 추가
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📊 실시간 온습도 환경 분석', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.red),
                    const SizedBox(width: 4),
                    const Text('온도', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.circle, size: 10, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text('습도', style: TextStyle(fontSize: 12)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            // 이중축을 적용한 LineChart 구성
            SizedBox(
              height: 220,
              child: tempSpots.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                LineChartData(
                  lineTouchData: const LineTouchData(enabled: false),

                  minY: 0,    //온습도 모두 0에서 시작
                  maxY: 100,  //최대 100으로 고정하여 안정적인 스케일 확보
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    //상단, 하단 축 타이틀은 숨김 (X축은 데이터 인덱스이므로 생략)
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

                    // 왼쪽 Y축: 온도 (℃)
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('온도(℃)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                      axisNameSize: 20,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          if (value % 20 != 0) return const SizedBox.shrink(); // 20 단위로만 표시
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 11, color: Colors.red));
                        },
                      ),
                  ),

                    // 오른쪽 Y축: 습도 (%)
                    rightTitles: AxisTitles(
                      axisNameWidget: const Text('습도(%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                      axisNameSize: 20,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          if (value % 20 != 0) return const SizedBox.shrink(); // 20 단위로만 표시
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 11, color: Colors.blue));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: tempSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    // 두 번째 선: 습도
                    LineChartBarData(
                      spots: humiditySpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
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
                      title: FittedBox(
                        child: Text(
                          alert['message'] ?? '진단결과',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
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