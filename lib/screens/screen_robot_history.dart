// lib/screen_robot_history.dart (또는 lib/screens/screen_robot_history.dart)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/app_theme.dart';

class RobotHistoryScreen extends StatefulWidget {
  final String currentUserId;

  const RobotHistoryScreen({super.key, required this.currentUserId});

  @override
  State<RobotHistoryScreen> createState() => _RobotHistoryScreenState();
}

class _RobotHistoryScreenState extends State<RobotHistoryScreen> {
  List<dynamic> _historyLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistoryLogs();
  }

  // 백엔드 API에서 로봇 제어 이력 데이터 가져오기
  Future<void> _fetchHistoryLogs() async {
    try {
      final url = Uri.parse(ApiConfig.commandLogsUrl(widget.currentUserId));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success' && responseData['data'] != null) {
          setState(() {
            _historyLogs = responseData['data'];
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('❌ 로봇 제어 이력 로드 실패: $e');
    }

    // 에러가 나거나 데이터가 없을 경우 로딩만 종료
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로봇 제어 기록'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _historyLogs.isEmpty
          ? const Center(
        child: Text('최근 로봇 제어 기록이 없습니다.', style: TextStyle(color: Colors.grey)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _historyLogs.length,
        itemBuilder: (context, index) {
          final log = _historyLogs[index];
          // API 응답 데이터 필드 구조에 맞게 수정하여 사용하세요 (예: command, timestamp, zone 등)
          final command = log['command'] ?? '알 수 없는 명령';
          final time = log['timestamp'] ?? '시간 정보 없음';
          final zone = log['zone'] ?? '-';

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.buttonBg,
                child: Icon(Icons.history, color: AppColors.primary),
              ),
              title: Text(
                '명령: $command',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text('구역: $zone | 시간: $time'),
            ),
          );
        },
      ),
    );
  }
}