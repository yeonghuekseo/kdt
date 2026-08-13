// lib/screens/screen_robot_history.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';

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

  Future<void> _fetchHistoryLogs() async {
    try {
      final url = Uri.parse(ApiConfig.commandLogsUrl(widget.currentUserId));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          setState(() { _historyLogs = responseData['data']; _isLoading = false; });
          return;
        }
      }
    } catch (e) { debugPrint('❌ 로봇 제어 이력 로드 실패: $e'); }
    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.history_rounded, size: 72, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Text('최근 로봇 제어 기록이 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 [모듈화 적용] 코드가 눈에 띄게 줄어듦
    return EcoGlassScaffold(
      title: const Text('로봇 제어 기록'),
      builder: (context, topPadding, bottomPadding) {
        if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (_historyLogs.isEmpty) return _buildEmptyState();

        return ListView.builder(
          // 🌟 모듈에서 넘겨준 자동 계산 패딩 사용
          padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: bottomPadding),
          itemCount: _historyLogs.length,
          itemBuilder: (context, index) {
            final log = _historyLogs[index];
            final command = log['command'] ?? '알 수 없는 명령';
            final time = log['timestamp'] ?? '시간 정보 없음';
            final zone = log['zone'] ?? '-';

            return Card(
              elevation: 0, margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary),
                ),
                title: Text('명령: $command', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text('구역: $zone | 시간: $time'),
              ),
            );
          },
        );
      },
    );
  }
}