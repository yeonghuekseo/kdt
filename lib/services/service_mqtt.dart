// lib/services/service_mqtt.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../core/api_config.dart';

// 🌟 [개선됨] 싱글톤 패턴 및 유저 세션 관리 강화
class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? _client;
  bool _isConnected = false;
  String? _currentUserId; // 현재 연결된 유저 식별

  // 앱 전체에 메시지를 뿌려줄 방송국
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect(String userId) async {
    // 🌟 유저가 바뀌었으면 기존 연결 강제 종료 후 재연결
    if (_isConnected && _currentUserId != userId) {
      debugPrint('🔄 유저 변경 감지: 기존 연결($_currentUserId) 종료 후 신규 연결($userId) 시작');
      disconnect();
    }

    if (_isConnected) return;

    _currentUserId = userId;
    final String clientId = 'flutter_global_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(ApiConfig.serverIp, clientId);
    _client!.port = ApiConfig.mqttPort;
    _client!.keepAlivePeriod = 20;
    _client!.logging(on: false);

    _client!.onDisconnected = () {
      debugPrint('MQTT Global Disconnected.');
      _isConnected = false;
      // 자동 재연결 로직 (유저가 로그아웃하지 않은 상태에서 끊겼을 때만)
      if (_currentUserId == userId) {
        Future.delayed(const Duration(seconds: 5), () {
          if (_currentUserId == userId) connect(userId);
        });
      }
    };

    final connMess = MqttConnectMessage().withClientIdentifier(clientId).startClean();
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
      _isConnected = true;
      debugPrint('MQTT Global Connected for $userId!');

      // 전역 토픽 구독
      _client!.subscribe('ddalgi/robot/status', MqttQos.atMostOnce);
      _client!.subscribe(ApiConfig.diseaseAlertTopic(userId), MqttQos.atMostOnce);

      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        try {
          final Map<String, dynamic> data = jsonDecode(pt);
          data['topic'] = c[0].topic;
          _messageController.add(data);
        } catch (e) {
          debugPrint('❌ MQTT 데이터 파싱 에러: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ MQTT 연결 실패: $e');
      _client?.disconnect();
      _isConnected = false;
      _currentUserId = null;
    }
  }

  // 🌟 명시적 연결 종료 (로그아웃 시 필수 호출)
  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
    _currentUserId = null;
    debugPrint('🔌 MQTT 연결이 완전히 종료되었습니다.');
  }
}
