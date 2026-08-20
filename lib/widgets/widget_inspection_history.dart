// lib/widgets/widget_inspection_history.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// 🌟 변경됨: 리스트 타일을 그리는 로직을 별도로 분리한 위젯 생성
class InspectionHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> logs;

  const InspectionHistoryWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const Center(child: Text('조회 이력이 없습니다.', style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      padding: EdgeInsets.zero, // 🌟 변경됨: 부모의 Expanded 영역에 딱 맞게 패딩 제거
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final isAlert = log['health_status'] == '경고' || log['health_status'] == '위험';

        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isAlert ? Colors.red.shade200 : Colors.grey.shade200)
          ),
          child: ListTile(
            leading: log['image_url'] != null
                ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(log['image_url'], width: 50, height: 50, fit: BoxFit.cover)
            )
                : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: isAlert ? Colors.red.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle
              ),
              child: Icon(
                  isAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                  color: isAlert ? Colors.red : AppColors.primary
              ),
            ),
            title: Text(
                log['message'] ?? '정상 조회 완료',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isAlert ? Colors.red.shade700 : Colors.black87)
            ),
            subtitle: Text('구역: ${log['zone'] ?? '-'} | 상태: ${log['health_status'] ?? '정상'} | 시간: ${log['timestamp'] ?? '-'}'),
          ),
        );
      },
    );
  }
}