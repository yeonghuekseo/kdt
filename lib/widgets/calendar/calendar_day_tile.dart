import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/app_constants.dart';
import '../../providers/environment_provider.dart';

class CalendarDayTile extends StatelessWidget {
  final DateTime date;
  final EnvDailyData? env;
  final String? harvestIcon, note;
  final bool hasDisease, isCurrentMonth, isToday;
  final VoidCallback onTap;

  const CalendarDayTile({
    super.key,
    required this.date,
    this.env,
    this.harvestIcon,
    this.note,
    required this.hasDisease,
    required this.isCurrentMonth,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 수치 판단 로직
    final bool isTempHigh = env != null && env!.maxTemp >= AppConstants.tempHighLimit;
    final bool isTempLow = env != null && env!.minTemp <= AppConstants.tempLowLimit;
    final bool isHumidHigh = env != null && env!.maxHumid >= AppConstants.humidHighLimit;
    final bool isHumidLow = env != null && env!.minHumid <= AppConstants.humidLowLimit;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isToday ? AppColors.primary : Colors.grey.shade200, width: isToday ? 1.5 : 1),
        ),
        child: Opacity(
          opacity: isCurrentMonth ? 1 : 0.3,
          child: Stack(
            children: [
              // 1. 날짜 숫자 (좌측 상단)
              Positioned(top: 4, left: 4, child: Text('${date.day}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.normal))),
              
              // 2. 수확 아이콘 (우측 상단)
              if (harvestIcon != null) Positioned(top: 4, right: 4, child: Text(harvestIcon!, style: const TextStyle(fontSize: 10))),
              
              // 3. 중앙 수직 레이아웃 (높음 - 메모 - 낮음)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 위, 중앙, 아래로 분산
                    children: [
                      // 상단: 높음 알림 (↑)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isTempHigh) const Text('🌡️↑', style: TextStyle(fontSize: 7.5, color: Colors.red, fontWeight: FontWeight.bold)),
                          if (isTempHigh && isHumidHigh) const SizedBox(width: 2),
                          if (isHumidHigh) const Text('💧↑', style: TextStyle(fontSize: 7.5, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      
                      // 중앙: 메모 텍스트
                      if (note != null && note!.isNotEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              note!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 8.5, color: Colors.black87, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                      // 하단: 낮음 알림 (↓)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isTempLow) const Text('🌡️↓', style: TextStyle(fontSize: 7.5, color: Colors.red, fontWeight: FontWeight.bold)),
                          if (isTempLow && isHumidLow) const SizedBox(width: 2),
                          if (isHumidLow) const Text('💧↓', style: TextStyle(fontSize: 7.5, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. 최하단 상태 점 (질병 등 핵심 상태 표시 유지)
              Positioned(
                bottom: 2, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasDisease) _dot(3, Colors.amber),
                    if (harvestIcon != null) ...[
                       if (hasDisease) const SizedBox(width: 1),
                       _dot(3, Colors.orange),
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(double s, Color c) => Container(
    width: s,
    height: s,
    margin: const EdgeInsets.symmetric(horizontal: 0.5),
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
