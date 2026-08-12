// lib/controllers/robot_controller.dart
import 'package:flutter/material.dart';
import '../services/robot_control_service.dart';

class RobotController extends ChangeNotifier {
  final String userId;
  final String robotId;
  final RobotControlService _robotService = RobotControlService();

  // 화면 상태 데이터
  String currentZone = 'A1';
  double sliderValue = 0.0;
  bool isReturningHome = false;

  RobotController({required this.userId, required this.robotId});

  // [귀환 버튼 동작] 서버로 명령 전송 및 슬라이더 0 초기화
  void sendReturnCommand() {
    if (isReturningHome) return;

    isReturningHome = true;
    notifyListeners(); // 로딩 상태 알림

    // 통신병을 통해 백엔드로 귀환 명령 전송
    _robotService.sendCommandToRobot(
        userId: userId,
        robotId: robotId,
        command: 'return_home',
        onError: (errorMsg) {
          debugPrint('귀환 명령 에러: $errorMsg');
        }
    );

    // 즉시 슬라이더를 0.0(정지)으로 복귀 및 로딩 해제
    sliderValue = 0.0;
    isReturningHome = false;
    notifyListeners();
  }

  // 슬라이더 드래그 중 실시간 갱신
  void updateSliderDragging(double value) {
    sliderValue = value;
    notifyListeners();
  }

  // 슬라이더 드래그 종료 시 서버 전송
  void updateSliderEnd(double targetValue) {
    sliderValue = targetValue;
    notifyListeners();

    _robotService.sendSingleCommandForValue(
        targetValue: targetValue,
        userId: userId,
        robotId: robotId,
        zoneId: currentZone,
        onError: (errorMsg) {
          debugPrint('슬라이더 명령 에러: $errorMsg');
        }
    );
  }
}