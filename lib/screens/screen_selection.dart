// lib/screens/screen_selection.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🌟 분리된 전역 상태 Provider들 임포트
import '../providers/auth_provider.dart';
import '../providers/crop_provider.dart';
import '../providers/environment_provider.dart';
import '../providers/alert_provider.dart';

import '../core/app_theme.dart';
import '../widgets/app_widgets.dart'; // GlassAppBar 사용
import 'screen_settings.dart';
import 'tabs/tab_farm_monitor.dart';
import 'tabs/tab_robot_control.dart';

class FruitSelectionScreen extends StatefulWidget {
  const FruitSelectionScreen({super.key});

  @override
  State<FruitSelectionScreen> createState() => _FruitSelectionScreenState();
}

class _FruitSelectionScreenState extends State<FruitSelectionScreen> {
  int _currentIndex = 0; // 하단 네비게이션 탭 인덱스
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 최초 빌드될 때 딱 한 번만 전역 데이터 초기화 실행
    if (!_isInit) {
      _initializeGlobalData();
      _isInit = true;
    }
  }

  void _initializeGlobalData() {
    final userId = context.read<AuthProvider>().currentUser?.userId ?? '';
    // 1. 작물 리스트 전역 로드 (설정 화면, 대시보드 화면이 공유)
    context.read<CropProvider>().fetchCrops(userId);
    // 2. 농장 온습도 로그 전역 로드 (모니터링 탭에서 사용)
    context.read<EnvironmentProvider>().fetchEnvironmentLogs(userId);
    // 3. 백그라운드 이상 감지 알림 및 싱글톤 MQTT 연결 시작
    context.read<AlertProvider>().init(userId);
  }

  @override
  Widget build(BuildContext context) {
    final alertCount = context.watch<AlertProvider>().alertLogs.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: const Text('스마트팜 통합 관제'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              final currentFruits = context.read<CropProvider>().crops;
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(currentFruits: currentFruits))
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          // 하위 탭들 역시 더 이상 userId나 fruits 같은 파라미터를 넘겨받지 않습니다.
          // 내부에서 직접 context.watch<Provider>로 데이터를 꺼내 씁니다.
          TabFarmMonitor(),
          TabRobotControl(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none, // 뱃지가 아이콘 영역 밖으로 튀어나가는 것을 허용
              children: [
                const Icon(Icons.dashboard_rounded),
                // 🌟 [추가된 UI] 알림 전역화의 이점: 로봇 제어 탭에 있더라도 알림이 오면 모니터링 아이콘에 빨간 뱃지가 뜹니다.
                if (alertCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        alertCount > 99 ? '99+' : '$alertCount',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            label: '모니터링',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_rounded),
            label: '로봇 제어',
          ),
        ],
      ),
    );
  }
}