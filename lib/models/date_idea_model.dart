import 'package:uuid/uuid.dart';

enum DateCategory { romantic, adventure, cozy, creative, foodie, outdoor }

class DateIdeaModel {
  final String id;
  final String title;
  final String description;
  final DateCategory category;
  final String? imageAsset;
  final int estimatedCost; // 1-4 ($ to $$$$)
  final int estimatedTime; // in minutes
  final bool isCompleted;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateIdeaModel({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    this.imageAsset,
    this.estimatedCost = 2,
    this.estimatedTime = 120,
    this.isCompleted = false,
    this.completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get categoryEmoji {
    switch (category) {
      case DateCategory.romantic: return '💕';
      case DateCategory.adventure: return '🎢';
      case DateCategory.cozy: return '🛋️';
      case DateCategory.creative: return '🎨';
      case DateCategory.foodie: return '🍽️';
      case DateCategory.outdoor: return '🌿';
    }
  }

  String get categoryLabel {
    switch (category) {
      case DateCategory.romantic: return 'Romantic';
      case DateCategory.adventure: return 'Adventure';
      case DateCategory.cozy: return 'Cozy Night In';
      case DateCategory.creative: return 'Creative';
      case DateCategory.foodie: return 'Foodie';
      case DateCategory.outdoor: return 'Outdoor';
    }
  }

  String get costLabel => '\$' * estimatedCost;

  String get timeLabel {
    if (estimatedTime < 60) return '$estimatedTime min';
    final hours = estimatedTime ~/ 60;
    final mins = estimatedTime % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  Map<String, dynamic> toJson({String? coupleId, String? userId}) => {
    'id': id,
    if (coupleId != null) 'couple_id': coupleId,
    if (userId != null) 'user_id': userId,
    'title': title,
    'description': description,
    'category': category.name,
    'image_asset': imageAsset,
    'estimated_cost': estimatedCost,
    'estimated_time': estimatedTime,
    'is_completed': isCompleted,
    'completed_date': completedDate?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory DateIdeaModel.fromJson(Map<String, dynamic> json) {
    DateCategory parseCategory() {
      final catValue = json['category'];
      if (catValue is int) return DateCategory.values[catValue];
      if (catValue is String) {
        return DateCategory.values.firstWhere((c) => c.name == catValue, orElse: () => DateCategory.romantic);
      }
      return DateCategory.romantic;
    }

    return DateIdeaModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: parseCategory(),
      imageAsset: (json['image_asset'] ?? json['imageAsset']) as String?,
      estimatedCost: (json['estimated_cost'] ?? json['estimatedCost'] as int?) ?? 2,
      estimatedTime: (json['estimated_time'] ?? json['estimatedTime'] as int?) ?? 120,
      isCompleted: (json['is_completed'] ?? json['isCompleted'] as bool?) ?? false,
      completedDate: (json['completed_date'] ?? json['completedDate']) != null 
          ? DateTime.parse((json['completed_date'] ?? json['completedDate']) as String) 
          : null,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt']) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String),
    );
  }

  DateIdeaModel copyWith({
    String? title,
    String? description,
    DateCategory? category,
    String? imageAsset,
    int? estimatedCost,
    int? estimatedTime,
    bool? isCompleted,
    DateTime? completedDate,
  }) => DateIdeaModel(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    imageAsset: imageAsset ?? this.imageAsset,
    estimatedCost: estimatedCost ?? this.estimatedCost,
    estimatedTime: estimatedTime ?? this.estimatedTime,
    isCompleted: isCompleted ?? this.isCompleted,
    completedDate: completedDate ?? this.completedDate,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
