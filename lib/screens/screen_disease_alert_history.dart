// lib/screens/screen_disease_alert_history.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart'; //[cite: 3]
import '../core/app_theme.dart'; //[cite: 4, 7]

class ScreenDiseaseAlertHistory extends StatefulWidget {
  final String currentUserId;

  const ScreenDiseaseAlertHistory({super.key, required this.currentUserId});

  @override
  State<ScreenDiseaseAlertHistory> createState() => _ScreenDiseaseAlertHistoryState();
}

class _ScreenDiseaseAlertHistoryState extends State<ScreenDiseaseAlertHistory> {
  List<dynamic> _diseaseLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiseaseLogs();
  }

  Future<void> _fetchDiseaseLogs() async {
    try {
      final url = Uri.parse(ApiConfig.cropLogsUrl(widget.currentUserId)); //[cite: 3]
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          setState(() {
            _diseaseLogs = responseData['data'];
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('❌ AI 질병 진단 로그 로드 실패: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 비전 진단 전체 이력'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) //[cite: 4, 7]
          : _diseaseLogs.isEmpty
          ? const Center(child: Text('저장된 질병 진단 이력이 없습니다.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _diseaseLogs.length,
        itemBuilder: (context, index) {
          final log = _diseaseLogs[index];
          final message = log['message'] ?? '이상 증상 감지';
          final zone = log['zone'] ?? '-';
          final status = log['health_status'] ?? '주의';
          final imageUrl = log['image_url'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: imageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
                  : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: AppColors.alertCardBg, borderRadius: BorderRadius.circular(8)), //[cite: 4, 7]
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              ),
              title: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text('촬영 구역: $zone  |  건강 상태: $status', style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ),
            ),
          );
        },
      ),
    );
  }
}