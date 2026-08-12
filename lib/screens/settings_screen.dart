// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'crop_edit_screen.dart';

class SettingsScreen extends StatefulWidget {
  final List<Map<String, String>> currentFruits;

  const SettingsScreen({super.key, required this.currentFruits});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late List<Map<String, String>> _currentFruits;

  @override
  void initState() {
    super.initState();
    _currentFruits = List.from(widget.currentFruits);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _currentFruits);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('농장 설정'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _currentFruits),
          ),
        ),
        body: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '일반 설정',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.local_florist, color: AppColors.primary, size: 28),
              title: const Text('작물 등록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: const Text('대시보드에 표시될 작물 이름과 아이콘 변경'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () async {
                final updatedFruits = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CropEditScreen(currentFruits: _currentFruits),
                  ),
                );

                if (updatedFruits != null && updatedFruits is List<Map<String, String>>) {
                  setState(() {
                    _currentFruits = updatedFruits;
                  });
                }
              },
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}