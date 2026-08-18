// lib/controllers/fruit_dashboard_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/api_config.dart';
import '../services/service_api.dart';

class RipenessData {
  final String date;
  final int unripeCount;   // 미숙
  final int ripeCount;     // 적숙
  final int overripeCount; // 과숙

  RipenessData({required this.date, required this.unripeCount, required this.ripeCount, required this.overripeCount});
}

class FruitDashboardController extends ChangeNotifier {
  final String userId;
  final String fruitCode;
  final String fruitName;
  final void Function(String newZone)? onZoneUpdated;

  MqttServerClient? client;
  bool isConnected = false;
  List<RipenessData> ripenessList = [];
  final List<Map<String, dynamic>> alertLogs = [];

  FruitDashboardController({
    required this.userId,
    required this.fruitCode,
    required this.fruitName,
    this.onZoneUpdated,
  }) {
    loadInitialData();
    initMqtt();
  }

  @override
  void dispose() {
    client?.disconnect();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    final url = ApiConfig.cropSummaryUrl(userId, fruitCode);
    final responseData = await ApiService.get(url);

    if(responseData != null && responseData['status'] == 'success' && responseData['data'] != null) {
      final Map<String, dynamic> data = responseData['data'];

      if(data.containsKey('growth_ranges') && data['growth_ranges'] is List) {
        final List<dynamic> ranges = data['growth_ranges'];

        ripenessList = ranges.map((item) {
          return RipenessData(
              date: item['data']?.toString() ?? '알수없음',
              unripeCount: int.tryParse(item['unripe']?.toString() ?? '0') ?? 0,
              ripeCount: int.tryParse(item['ripe']?.toString() ?? '0') ?? 0,
              overripeCount: int.tryParse(item['overripe']?.toString() ?? '0') ?? 0
          );
        }).toList();
      }
    }else{
      ripenessList = [];
    }
        notifyListeners();
    }


  Future<void> initMqtt() async {
    final String clientId = 'flutter_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    client = MqttServerClient(ApiConfig.serverIp, clientId);
    client!.port = ApiConfig.mqttPort;
    client!.keepAlivePeriod = 20;
    client!.logging(on: false);

    client!.onDisconnected = () {
      debugPrint('⚠️ MQTT 연결 끊김. 5초 후 재연결 시도...');
      isConnected = false;
      notifyListeners();
      Future.delayed(const Duration(seconds: 5), () => initMqtt());
    };

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
          if(data.containsKey('zone') && onZoneUpdated != null) {
            onZoneUpdated!(data['zone'].toString());
          }
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

  void _handleDiseaseAlert(Map<String, dynamic> alertData) {
    alertLogs.insert(0, alertData);
    notifyListeners();
  }
}