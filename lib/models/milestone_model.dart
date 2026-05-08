import 'package:uuid/uuid.dart';

enum MilestoneType { anniversary, firstDate, engagement, wedding, travel, achievement, custom }

class MilestoneModel {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final MilestoneType type;
  final String? imageAsset;
  final DateTime createdAt;
  final DateTime updatedAt;

  MilestoneModel({
    String? id,
    required this.title,
    this.description,
    required this.date,
    required this.type,
    this.imageAsset,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get typeEmoji {
    switch (type) {
      case MilestoneType.anniversary: return '💍';
      case MilestoneType.firstDate: return '💕';
      case MilestoneType.engagement: return '💎';
      case MilestoneType.wedding: return '👰';
      case MilestoneType.travel: return '✈️';
      case MilestoneType.achievement: return '🏆';
      case MilestoneType.custom: return '⭐';
    }
  }

  String get typeLabel {
    switch (type) {
      case MilestoneType.anniversary: return 'Anniversary';
      case MilestoneType.firstDate: return 'First Date';
      case MilestoneType.engagement: return 'Engagement';
      case MilestoneType.wedding: return 'Wedding';
      case MilestoneType.travel: return 'Travel';
      case MilestoneType.achievement: return 'Achievement';
      case MilestoneType.custom: return 'Special Moment';
    }
  }

  int get daysUntil {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, date.month, date.day);
    final nextOccurrence = thisYear.isBefore(now) 
        ? DateTime(now.year + 1, date.month, date.day)
        : thisYear;
    return nextOccurrence.difference(now).inDays;
  }

  int get yearsAgo {
    final now = DateTime.now();
    return now.year - date.year;
  }

  Map<String, dynamic> toJson({String? coupleId}) => {
    'id': id,
    if (coupleId != null) 'couple_id': coupleId,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'type': type.name,
    'image_asset': imageAsset,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    MilestoneType parseType() {
      final typeValue = json['type'];
      if (typeValue is int) return MilestoneType.values[typeValue];
      if (typeValue is String) {
        return MilestoneType.values.firstWhere((t) => t.name == typeValue, orElse: () => MilestoneType.custom);
      }
      return MilestoneType.custom;
    }

    return MilestoneModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      type: parseType(),
      imageAsset: (json['image_asset'] ?? json['imageAsset']) as String?,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt']) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String),
    );
  }

  MilestoneModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    MilestoneType? type,
    String? imageAsset,
  }) => MilestoneModel(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    date: date ?? this.date,
    type: type ?? this.type,
    imageAsset: imageAsset ?? this.imageAsset,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
