import 'package:uuid/uuid.dart';

enum InAppNotificationType {
  growthReminder,
  appreciationPrompt,
  peaceLilyReceived,
  partnerAcceptedPairing,
  weeklyDigest,
  streakCelebration,
  system,
}

class InAppNotificationModel {
  final String id;
  final InAppNotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  InAppNotificationModel({
    String? id,
    required this.type,
    required this.title,
    required this.body,
    this.payload = const {},
    this.isRead = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'payload': payload,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory InAppNotificationModel.fromJson(Map<String, dynamic> json) {
    final typeName = (json['type'] as String?) ?? InAppNotificationType.system.name;
    final type = InAppNotificationType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => InAppNotificationType.system,
    );

    return InAppNotificationModel(
      id: (json['id'] as String?) ?? const Uuid().v4(),
      type: type,
      title: (json['title'] as String?) ?? 'Notification',
      body: (json['body'] as String?) ?? '',
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      isRead: (json['is_read'] ?? json['isRead'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] as String?) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  InAppNotificationModel copyWith({
    InAppNotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    bool? isRead,
  }) =>
      InAppNotificationModel(
        id: id,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        payload: payload ?? this.payload,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
