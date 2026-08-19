// lib/services/service_mqtt.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../core/api_config.dart';

// 🌟 [전역화 수정 포인트] 싱글톤(Singleton) 패턴 적용: 앱 전체에서 단 하나의 인스턴스만 존재
class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? _client;
  bool _isConnected = false;

  // 앱 전체에 메시지를 뿌려줄 방송국(StreamController) 생성
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect(String userId) async {
    if (_isConnected) return; // 이미 연결되어 있으면 무시

    final String clientId = 'flutter_global_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(ApiConfig.serverIp, clientId);
    _client!.port = ApiConfig.mqttPort;
    _client!.keepAlivePeriod = 20;
    _client!.logging(on: false);

    _client!.onDisconnected = () {
      debugPrint('MQTT Global Disconnected. Reconnecting in 5s...');
      _isConnected = false;
      Future.delayed(const Duration(seconds: 5), () => connect(userId));
    };

    final connMess = MqttConnectMessage().withClientIdentifier(clientId).startClean();
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
      _isConnected = true;
      debugPrint('MQTT Global Connected!');

      // 전역 토픽 구독
      _client!.subscribe('ddalgi/robot/status', MqttQos.atMostOnce);
      _client!.subscribe(ApiConfig.diseaseAlertTopic(userId), MqttQos.atMostOnce);

      // 메시지 수신 시 스트림에 흘려보냄
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        try {
          final Map<String, dynamic> data = jsonDecode(pt);
          data['topic'] = c[0].topic; // 토픽 정보를 데이터에 포함시킴
          _messageController.add(data); // 🌟 스트림을 듣고 있는 모든 Provider에게 브로드캐스트
        } catch (e) {
          debugPrint('❌ MQTT 연결 실패 상세 원인: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ MQTT 상태 코드: ${_client!.connectionStatus!.returnCode}');
      _client?.disconnect();
      _isConnected = false;
    }
  }
}