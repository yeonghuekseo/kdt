// lib/screens/screen_crop_edit.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/service_crop_data.dart';

class CropEditScreen extends StatefulWidget {
  final List<Map<String, String>> currentFruits;
  const CropEditScreen({super.key, required this.currentFruits});
  @override
  State<CropEditScreen> createState() => _CropEditScreenState();
}

class _CropEditScreenState extends State<CropEditScreen> {
  late List<Map<String, String>> _editableFruits;

  @override
  void initState() {
    super.initState();
    _editableFruits = List.from(widget.currentFruits.map((fruit) => Map<String, String>.from(fruit)));
  }

  void _editFruitDialog(int index) {
    final nameController = TextEditingController(text: _editableFruits[index]['name'] ?? '');
    final iconController = TextEditingController(text: _editableFruits[index]['icon'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('작물 편집'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: iconController, decoration: const InputDecoration(labelText: '이모지 (아이콘)', hintText: '예: 🍉')),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: '작물 이름', hintText: '예: 수박')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _editableFruits[index]['name'] = nameController.text.trim();
                  _editableFruits[index]['icon'] = iconController.text.trim();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 [모듈화 적용]
    return EcoGlassScaffold(
      title: const Text('작물 등록'),
      builder: (context, topPadding, bottomPadding) {
        return Padding(
          // 🌟 모듈에서 넘겨준 자동 계산 패딩 사용
          padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('대시보드 작물 리스트 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8),
              const Text('수정할 작물을 터치하여 이름과 아이콘을 변경할 수 있습니다.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _editableFruits.length,
                  itemBuilder: (context, index) {
                    final fruit = _editableFruits[index];
                    return Card(
                      elevation: 0, margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                      child: ListTile(
                        leading: SizedBox(width: 50, child: FittedBox(fit: BoxFit.scaleDown, child: Text(fruit['icon'] ?? '🌱', style: const TextStyle(fontSize: 32)))),
                        title: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(fruit['name'] ?? '알 수 없는 작물', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        subtitle: Text('작물 ID: ${fruit['crop_id'] ?? fruit['code'] ?? '없음'}'),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                        ),
                        onTap: () => _editFruitDialog(index),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: '변경 사항 적용 및 영구 저장',
                onPressed: () async {
                  await CropDataService.saveLocalCropMetadata(_editableFruits);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 설정이 기기에 저장되었습니다.')));
                  Navigator.pop(context, _editableFruits);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
