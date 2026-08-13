// lib/screens/screen_disease_alert_history.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';

class ScreenDiseaseAlertHistory extends StatefulWidget {
  final String currentUserId;
  const ScreenDiseaseAlertHistory({super.key, required this.currentUserId});
  @override
  State<ScreenDiseaseAlertHistory> createState() => _ScreenDiseaseAlertHistoryState();
}

class _ScreenDiseaseAlertHistoryState extends State<ScreenDiseaseAlertHistory> {
  List<dynamic> _diseaseLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiseaseLogs();
  }

  Future<void> _fetchDiseaseLogs() async {
    try {
      final url = Uri.parse(ApiConfig.cropLogsUrl(widget.currentUserId));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          setState(() { _diseaseLogs = responseData['data']; _isLoading = false; });
          return;
        }
      }
    } catch (e) { debugPrint('❌ AI 질병 진단 로그 로드 실패: $e'); }
    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: AppColors.alertCardBg, shape: BoxShape.circle),
            child: Icon(Icons.inbox_rounded, size: 72, color: Colors.red.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Text('저장된 질병 진단 이력이 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 [모듈화 적용] 반복되던 설정 코드 완전 삭제
    return EcoGlassScaffold(
      title: const Text('AI 비전 진단 전체 이력'),
      builder: (context, topPadding, bottomPadding) {
        if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (_diseaseLogs.isEmpty) return _buildEmptyState();

        return ListView.builder(
          // 🌟 모듈에서 넘겨준 자동 계산 패딩 사용
          padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: bottomPadding),
          itemCount: _diseaseLogs.length,
          itemBuilder: (context, index) {
            final log = _diseaseLogs[index];
            final message = log['message'] ?? '이상 증상 감지';
            final zone = log['zone'] ?? '-';
            final status = log['health_status'] ?? '주의';
            final imageUrl = log['image_url'];

            return Card(
              margin: const EdgeInsets.only(bottom: 12), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.withValues(alpha: 0.1))),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: imageUrl != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_rounded, color: Colors.grey)))
                    : Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.warning_amber_rounded, color: Colors.red)),
                title: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Padding(padding: const EdgeInsets.only(top: 6.0), child: Text('촬영 구역: $zone  |  건강 상태: $status', style: const TextStyle(fontSize: 12, color: Colors.black87))),
              ),
            );
          },
        );
      },
    );
  }
}