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

  // ===========================================================================
  // [1. 상태 초기화] 원본 데이터 훼손 방지를 위한 복사본 생성
  // ===========================================================================
  @override
  void initState() {
    super.initState();
    _editableFruits = List.from(widget.currentFruits.map((fruit) => Map<String, String>.from(fruit)));
  }

  // ===========================================================================
  // [2. 다이얼로그 팝업] 특정 인덱스의 과일 정보(이름, 아이콘)를 수정하는 창 띄우기
  // ===========================================================================
  void _editFruitDialog(int index) {
    final nameController = TextEditingController(text: _editableFruits[index]['name'] ?? '');
    final iconController = TextEditingController(text: _editableFruits[index]['icon'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('작물 편집'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: '이모지 (아이콘)', hintText: '예: 🍉'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '작물 이름', hintText: '예: 수박'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _editableFruits[index]['name'] = nameController.text.trim();
                  _editableFruits[index]['icon'] = iconController.text.trim();
                });
                Navigator.pop(context); // 팝업 닫기
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // [3. UI 렌더링] 작물 리스트 및 하단 저장 버튼
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('작물 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '대시보드 작물 리스트 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            const Text('수정할 작물을 터치하여 이름과 아이콘을 변경할 수 있습니다.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _editableFruits.length,
                itemBuilder: (context, index) {
                  final fruit = _editableFruits[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      // 🌟 수정 1: Null 에러 방지(??) 및 이모티콘을 많이 넣어도 깨지지 않게 FittedBox 추가
                      leading: SizedBox(
                        width: 50, // 최대 가로 영역을 정해줌
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(fruit['icon'] ?? '🌱', style: const TextStyle(fontSize: 32)),
                        ),
                      ),

                      // 🌟 수정 2: 이름(name) Null 에러 방지(??) 및 긴 글자 자동 축소 기능 추가
                      title: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                            fruit['name'] ?? '알 수 없는 작물',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                        ),
                      ),

                      // 🌟 수정 3: 구버전 데이터(code)와 신버전 데이터(crop_id) 모두 대응하여 Null 방지
                      subtitle: Text('작물 ID: ${fruit['crop_id'] ?? fruit['code'] ?? '없음'} (서버 연동)'),
                      trailing: const Icon(Icons.edit, color: AppColors.primary),
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
                // 비동기로 내부 저장소에 기록
                await CropDataService.saveLocalCropMetadata(_editableFruits);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 설정이 기기에 저장되었습니다.')),
                );

                // 설정이 완료된 리스트를 이전 화면으로 반환
                Navigator.pop(context, _editableFruits);
              },
            ),
          ],
        ),
      ),
    );
  }
}