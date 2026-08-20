// lib/screens/screen_selection.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/crop_provider.dart';
import '../providers/environment_provider.dart';
import '../providers/alert_provider.dart';

import '../core/app_theme.dart';
import '../widgets/app_widgets.dart'; 
import 'screen_settings.dart';
import 'screen_calendar.dart'; // 🌟 추가
import 'tabs/tab_farm_monitor.dart';
import 'tabs/tab_robot_control.dart';

class FruitSelectionScreen extends StatefulWidget {
  const FruitSelectionScreen({super.key});

  @override
  State<FruitSelectionScreen> createState() => _FruitSelectionScreenState();
}

class _FruitSelectionScreenState extends State<FruitSelectionScreen> {
  int _currentIndex = 0;
  bool _isInitialized = false; // 🌟 초기화 여부를 더 명확한 변수명으로 관리

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🌟 화면이 빌드될 때 세션 정보를 안전하게 가져와 한 번만 초기화 수행
    if (!_isInitialized) {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.userId ?? '';
      
      if (userId.isNotEmpty) {
        _initializeGlobalData(userId);
        _isInitialized = true;
      }
    }
  }

  void _initializeGlobalData(String userId) async {
    final cropProvider = context.read<CropProvider>();
    
    // 1. 작물 리스트 로드 (먼저 수행)
    await cropProvider.fetchCrops(userId);
    // 🌟 [추가] 작물 리스트가 로드된 후 모든 수확기 예측 실행
    await cropProvider.preCalculateAllHarvest(userId);

    if (!mounted) return;

    // 2. 농장 온습도 로그 로드
    context.read<EnvironmentProvider>().fetchEnvironmentLogs(userId);
    // 3. MQTT 연결 및 질병 알림 리스너 시작
    context.read<AlertProvider>().init(userId);
  }

  @override
  Widget build(BuildContext context) {
    // 알림 개수 실시간 감시
    final alertCount = context.watch<AlertProvider>().alertLogs.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: const Text('스마트팜 통합 관제'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
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
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.dashboard_rounded),
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
