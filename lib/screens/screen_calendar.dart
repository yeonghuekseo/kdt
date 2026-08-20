// lib/screens/screen_calendar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_widgets.dart';
import '../widgets/calendar/calendar_day_tile.dart';
import '../widgets/calendar/calendar_legend.dart';
import '../core/app_theme.dart';
import '../providers/crop_provider.dart';
import '../providers/environment_provider.dart';
import '../providers/alert_provider.dart';
// import '../controllers/controller_fruit_dashboard.dart'; // 🌟 Removed unused import

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _displayDate = DateTime.now();

  void _moveMonth(int delta) {
    setState(() => _displayDate = DateTime(_displayDate.year, _displayDate.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(_displayDate.year, _displayDate.month, 1);
    final offset = firstDay.weekday % 7;
    
    return Consumer3<EnvironmentProvider, AlertProvider, CropProvider>(
      builder: (context, envP, alertP, cropP, _) {
        final diseaseSet = alertP.alertLogs.map((l) => (l['timestamp'] ?? '').toString().split(' ')[0]).toSet();
        final harvestMap = <String, String>{};
        cropP.harvestPeriods.forEach((_, range) {
          for (int i = 0; i <= range.end.difference(range.start).inDays; i++) {
            final d = range.start.add(Duration(days: i));
            harvestMap['${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}'] = range.fruitIcon;
          }
        });

        return EcoGlassScaffold(
          title: const Text('농장 활동 캘린더'),
          builder: (ctx, top, bottom) => SingleChildScrollView(
            padding: EdgeInsets.only(top: top, left: 10, right: 10, bottom: bottom),
            child: Column(
              children: [
                Card(
                  color: Colors.white, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _buildMonthHeader(),
                        const SizedBox(height: 16),
                        _buildWeekdayRow(),
                        const Divider(),
                        GridView.builder(
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 0.72),
                          itemCount: 42,
                          itemBuilder: (ctx, i) {
                            final date = firstDay.add(Duration(days: i - offset));
                            final ymd = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
                            final md = '${date.month.toString().padLeft(2,'0')}/${date.day.toString().padLeft(2,'0')}';
                            return CalendarDayTile(
                              key: ValueKey('tile_$ymd'),
                              date: date, env: envP.dailyMap[md], harvestIcon: harvestMap[ymd], hasDisease: diseaseSet.contains(ymd),
                              isCurrentMonth: date.month == _displayDate.month, isToday: date.year == now.year && date.month == now.month && date.day == now.day,
                              note: envP.getNoteForDate(ymd),
                              onTap: () => _showNoteDialog(context, date, envP.dailyMap[md], envP),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const CalendarLegend(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _moveMonth(-1)),
      Text('${_displayDate.year}년 ${_displayDate.month}월', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
      IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _moveMonth(1)),
    ],
  );

  Widget _buildWeekdayRow() {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(children: List.generate(7, (i) => Expanded(child: Center(child: Text(days[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: i==0?Colors.red:(i==6?Colors.blue:Colors.grey)))))));
  }

  void _showNoteDialog(BuildContext context, DateTime date, EnvDailyData? env, EnvironmentProvider provider) {
    final ymd = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
    final controller = TextEditingController(text: provider.getNoteForDate(ymd));
    showDialog<String>(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('${date.month}월 ${date.day}일 농장 기록'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (env != null) ...[
              _row('온도', '${env.minTemp}~${env.maxTemp}°C', Colors.red),
              _row('습도', '${env.minHumid}~${env.maxHumid}%', Colors.blue),
              const Divider(),
            ],
            TextField(controller: controller, maxLength: 8, decoration: const InputDecoration(hintText: '메모 (최대 8자)', counterText: "")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('저장')),
        ],
      ),
    ).then((savedText) {
      if (savedText != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => provider.saveNoteForDate(ymd, savedText));
      }
      controller.dispose();
    });
  }

  Widget _row(String l, String v, Color c) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12)), Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13))]));
}
