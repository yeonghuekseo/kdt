// lib/controllers/fruit_dashboard_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/api_config.dart';

class FruitDashboardController extends ChangeNotifier {
  final String userId;
  final String fruitName;

  MqttServerClient? client;
  bool isConnected = false;
  List<FlSpot> tempSpots = [];
  List<FlSpot> humiditySpots = [];
  int xCounter = 0;
  final List<Map<String, dynamic>> alertLogs = [];

  FruitDashboardController({required this.userId, required this.fruitName}) {
    loadInitialData();
    initMqtt();
  }

  @override
  void dispose() {
    client?.disconnect();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    try {
      final url = Uri.parse(ApiConfig.envLogsUrl(userId));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final List<dynamic> logs = responseData['data'];
          List<FlSpot> loadedTemp = [];
          List<FlSpot> loadedHumid = [];

          for (int i = 0; i < logs.length; i++) {
            double tValue = (logs[i]['temperature'] ?? 0.0).toDouble();
            double hValue = (logs[i]['humidity'] ?? 0.0).toDouble();
            loadedTemp.add(FlSpot(i.toDouble(), tValue));
            loadedHumid.add(FlSpot(i.toDouble(), hValue));
          }

          tempSpots = loadedTemp;
          humiditySpots = loadedHumid;
          xCounter = logs.length;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ 환경 로그 데이터 로드 실패: $e');
    }
  }

  Future<void> initMqtt() async {
    final String clientId = 'flutter_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    client = MqttServerClient(ApiConfig.serverIp, clientId);
    client!.port = ApiConfig.mqttPort;
    client!.keepAlivePeriod = 20;
    client!.logging(on: false);

    final connMess = MqttConnectMessage().withClientIdentifier(clientId).startClean();
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
      isConnected = true;
      notifyListeners();

      const String robotStatusTopic = 'ddalgi/robot/status';
      client!.subscribe(robotStatusTopic, MqttQos.atMostOnce);

      final String alertTopic = ApiConfig.diseaseAlertTopic(userId);
      client!.subscribe(alertTopic, MqttQos.atMostOnce);

      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final String receivedTopic = c[0].topic;
        final Map<String, dynamic> data = jsonDecode(pt);

        if (receivedTopic == robotStatusTopic) {
          _parseAndUpdateGraph(data);
        }
        if (receivedTopic == alertTopic) {
          _handleDiseaseAlert(data);
        }
      });
    } catch (e) {
      debugPrint('❌ MQTT 연결 실패: $e');
      client?.disconnect();
      isConnected = false;
      notifyListeners();
    }
  }

  void _parseAndUpdateGraph(Map<String, dynamic> data) {
    double tValue = (data['temperature'] ?? 0.0).toDouble();
    double hValue = (data['humidity'] ?? 0.0).toDouble();

    tempSpots.add(FlSpot(xCounter.toDouble(), tValue));
    humiditySpots.add(FlSpot(xCounter.toDouble(), hValue));
    xCounter++;

    if (tempSpots.length > 20) {
      tempSpots.removeAt(0);
      humiditySpots.removeAt(0);
    }
    notifyListeners();
  }

  void _handleDiseaseAlert(Map<String, dynamic> alertData) {
    alertLogs.insert(0, alertData);
    notifyListeners();
  }
}