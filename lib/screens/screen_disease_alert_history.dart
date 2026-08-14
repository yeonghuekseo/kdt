// lib/screens/screen_disease_alert_history.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../controllers/controller_disease_alert_history.dart'; // 🌟 새로 만든 컨트롤러 임포트

class ScreenDiseaseAlertHistory extends StatefulWidget {
  final String currentUserId;
  const ScreenDiseaseAlertHistory({super.key, required this.currentUserId});

  @override
  State<ScreenDiseaseAlertHistory> createState() => _ScreenDiseaseAlertHistoryState();
}

class _ScreenDiseaseAlertHistoryState extends State<ScreenDiseaseAlertHistory> {
  // 🌟 컨트롤러 인스턴스 생성
  final DiseaseAlertHistoryController _controller = DiseaseAlertHistoryController();

  @override
  void initState() {
    super.initState();
    // 🌟 화면 초기화 시 컨트롤러를 통해 데이터 조회 시작
    _controller.fetchDiseaseLogs(widget.currentUserId);
  }

  @override
  void dispose() {
    // 🌟 메모리 누수 방지를 위해 해제
    _controller.dispose();
    super.dispose();
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
    return EcoGlassScaffold(
      title: const Text('AI 비전 진단 전체 이력'),
      builder: (context, topPadding, bottomPadding) {

        // 🌟 ListenableBuilder 적용 (컨트롤러 상태 감지)
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {

            // 로딩 중이면서 데이터가 없을 때만 인디케이터 표시
            if (_controller.isLoading && _controller.diseaseLogs.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            // 🌟 RefreshIndicator(당겨서 새로고침) 적용
            return RefreshIndicator(
              onRefresh: () => _controller.fetchDiseaseLogs(widget.currentUserId),
              color: AppColors.primary,
              child: _controller.diseaseLogs.isEmpty
                  ? Stack(
                children: [
                  ListView(), // 당겨서 새로고침을 위한 빈 리스트
                  _buildEmptyState(),
                ],
              )
                  : ListView.builder(
                padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: bottomPadding),
                itemCount: _controller.diseaseLogs.length,
                itemBuilder: (context, index) {
                  final log = _controller.diseaseLogs[index];
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
              ),
            );
          },
        );
      },
    );
  }
}