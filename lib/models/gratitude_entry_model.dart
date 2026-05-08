import 'package:uuid/uuid.dart';

class GratitudeEntryModel {
  final String id;
  final String content;
  final String category;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  GratitudeEntryModel({
    String? id,
    required this.content,
    required this.category,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get categoryEmoji {
    switch (category.toLowerCase()) {
      case 'quality time': return '⏰';
      case 'acts of service': return '🤝';
      case 'words of affirmation': return '💬';
      case 'physical touch': return '🫂';
      case 'gifts': return '🎁';
      case 'support': return '💪';
      case 'adventure': return '✨';
      default: return '❤️';
    }
  }

  Map<String, dynamic> toJson({String? coupleId, String? userId}) => {
    'id': id,
    if (coupleId != null) 'couple_id': coupleId,
    if (userId != null) 'user_id': userId,
    'content': content,
    'category': category,
    'date': date.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory GratitudeEntryModel.fromJson(Map<String, dynamic> json) => GratitudeEntryModel(
    id: json['id'] as String,
    content: json['content'] as String,
    category: json['category'] as String,
    date: DateTime.parse(json['date'] as String),
    createdAt: DateTime.parse((json['created_at'] ?? json['createdAt']) as String),
    updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String),
  );

  GratitudeEntryModel copyWith({
    String? content,
    String? category,
  }) => GratitudeEntryModel(
    id: id,
    content: content ?? this.content,
    category: category ?? this.category,
    date: date,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
