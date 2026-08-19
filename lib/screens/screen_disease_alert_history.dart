// lib/screens/screen_disease_alert_history.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../providers/alert_provider.dart'; // 🌟 로컬 컨트롤러 대신 전역 Provider 사용

class ScreenDiseaseAlertHistory extends StatelessWidget {
  final String currentUserId;
  const ScreenDiseaseAlertHistory({super.key, required this.currentUserId});

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: AppColors.alertCardBg, shape: BoxShape.circle),
            child: Icon(Icons.inbox_rounded, size: 72, color: Colors.red),
          ),
          const SizedBox(height: 16),
          const Text('저장된 질병 진단 이력이 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 수정 부분: 상태 관리를 전역 AlertProvider로 위임
    final alertProvider = context.watch<AlertProvider>();
    final connected = alertProvider.isConnected;
    final diseaseLogs = alertProvider.alertLogs;

    return EcoGlassScaffold(
      title: const Text('AI 비전 진단 질병 경고 이력'),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: connected ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text(connected ? '실시간 수신중' : '수신 대기중', style: const TextStyle(fontSize: 10)),
            ],
          ),
        )
      ],
      builder: (context, topPadding, bottomPadding) {
        return diseaseLogs.isEmpty
            ? Stack(
          children: [
            ListView(),
            _buildEmptyState(),
          ],
        )
            : ListView.builder(
          padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: bottomPadding),
          itemCount: diseaseLogs.length,
          itemBuilder: (context, index) {
            final log = diseaseLogs[index];
            final message = log['message'] ?? '이상 증상 감지';
            final zone = log['zone'] ?? '-';
            final status = log['health_status'] ?? '경고';
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