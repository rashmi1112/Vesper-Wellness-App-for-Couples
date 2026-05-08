import 'package:uuid/uuid.dart';

enum MoodLevel { veryLow, low, neutral, good, great }

class CheckInModel {
  final String id;
  final DateTime date;
  final MoodLevel mood;
  final int connectionScore; // 1-10
  final String? note;
  final bool isPartner;
  final DateTime createdAt;
  final DateTime updatedAt;

  CheckInModel({
    String? id,
    required this.date,
    required this.mood,
    required this.connectionScore,
    this.note,
    this.isPartner = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get moodEmoji {
    switch (mood) {
      case MoodLevel.veryLow: return '😔';
      case MoodLevel.low: return '😐';
      case MoodLevel.neutral: return '🙂';
      case MoodLevel.good: return '😊';
      case MoodLevel.great: return '🥰';
    }
  }

  String get moodLabel {
    switch (mood) {
      case MoodLevel.veryLow: return 'Struggling';
      case MoodLevel.low: return 'Could be better';
      case MoodLevel.neutral: return 'Okay';
      case MoodLevel.good: return 'Good';
      case MoodLevel.great: return 'Amazing';
    }
  }

  Map<String, dynamic> toJson({String? coupleId, String? userId}) => {
    'id': id,
    if (coupleId != null) 'couple_id': coupleId,
    if (userId != null) 'user_id': userId,
    'date': date.toIso8601String(),
    'mood': mood.name,
    'connection_score': connectionScore,
    'note': note,
    'is_partner': isPartner,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    MoodLevel parseMood() {
      final moodValue = json['mood'];
      if (moodValue is int) return MoodLevel.values[moodValue];
      if (moodValue is String) {
        return MoodLevel.values.firstWhere((m) => m.name == moodValue, orElse: () => MoodLevel.neutral);
      }
      return MoodLevel.neutral;
    }

    return CheckInModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: parseMood(),
      connectionScore: (json['connection_score'] ?? json['connectionScore']) as int,
      note: json['note'] as String?,
      isPartner: (json['is_partner'] ?? json['isPartner'] as bool?) ?? false,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt']) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String),
    );
  }

  CheckInModel copyWith({
    MoodLevel? mood,
    int? connectionScore,
    String? note,
  }) => CheckInModel(
    id: id,
    date: date,
    mood: mood ?? this.mood,
    connectionScore: connectionScore ?? this.connectionScore,
    note: note ?? this.note,
    isPartner: isPartner,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
