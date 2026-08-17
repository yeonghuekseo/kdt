// lib/models/app_models.dart

class UserModel {
  final String userId;
  final String name;

  UserModel({required this.userId, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '알 수 없는 사용자',
    );
  }
}

class CropModel {
  final String cropId;
  String name;
  String icon;

  CropModel({required this.cropId, required this.name, required this.icon});

  factory CropModel.fromJson(String cropId, Map<String, dynamic> json) {
    return CropModel(
      cropId: cropId,
      name: json['name'] ?? '알 수 없는 작물',
      icon: json['icon'] ?? '🌱',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'icon': icon};
}