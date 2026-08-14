// lib/screens/screen_robot_history.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../controllers/controller_robot_history.dart'; // 🌟 새로 만든 컨트롤러 임포트

class RobotHistoryScreen extends StatefulWidget {
  final String currentUserId;
  const RobotHistoryScreen({super.key, required this.currentUserId});

  @override
  State<RobotHistoryScreen> createState() => _RobotHistoryScreenState();
}

class _RobotHistoryScreenState extends State<RobotHistoryScreen> {
  // 🌟 1. 상태 관리를 전담할 컨트롤러 인스턴스 생성
  final RobotHistoryController _controller = RobotHistoryController();

  @override
  void initState() {
    super.initState();
    // 🌟 2. 화면에 처음 진입할 때 컨트롤러에게 데이터 조회를 지시
    _controller.fetchHistoryLogs(widget.currentUserId);
  }

  @override
  void dispose() {
    // 위젯이 종료될 때 메모리 누수를 막기 위해 컨트롤러 해제
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
    return EcoGlassScaffold(
      title: const Text('로봇 제어 기록'),
      builder: (context, topPadding, bottomPadding) {
        // 🌟 3. ListenableBuilder를 통해 컨트롤러의 값이 바뀔 때만(notifyListeners 호출 시) 새로고침
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            // 로딩 중이면서 데이터가 비어있을 때만 중앙 인디케이터 표시
            if (_controller.isLoading && _controller.historyLogs.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            // 당겨서 새로고침
            return RefreshIndicator(
              onRefresh: () => _controller.fetchHistoryLogs(widget.currentUserId), // 컨트롤러의 조회 함수 호출
              color: AppColors.primary,
              child: _controller.historyLogs.isEmpty
                  ? Stack(
                children: [
                  ListView(),
                  _buildEmptyState(),
                ],
              )
                  : ListView.builder(
                padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: bottomPadding),
                itemCount: _controller.historyLogs.length, // 컨트롤러 안의 데이터 리스트 길이
                itemBuilder: (context, index) {
                  // 컨트롤러가 들고 있는 데이터를 바탕으로 화면 그림
                  final log = _controller.historyLogs[index];
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
              ),
            );
          },
        );
      },
    );
  }
}