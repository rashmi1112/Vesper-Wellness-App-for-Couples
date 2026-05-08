import 'package:uuid/uuid.dart';

enum AppreciationBadge {
  lily,
  cookies,
  cupcake,
  necklace,
  ring,
  sunshine,
  star,
  book,
  musicNote,
  coffeeCup,
}

extension AppreciationBadgeExtension on AppreciationBadge {
  String get emoji {
    switch (this) {
      case AppreciationBadge.lily:
        return '🌸';
      case AppreciationBadge.cookies:
        return '🍪';
      case AppreciationBadge.cupcake:
        return '🧁';
      case AppreciationBadge.necklace:
        return '📿';
      case AppreciationBadge.ring:
        return '💍';
      case AppreciationBadge.sunshine:
        return '☀️';
      case AppreciationBadge.star:
        return '⭐';
      case AppreciationBadge.book:
        return '📚';
      case AppreciationBadge.musicNote:
        return '🎵';
      case AppreciationBadge.coffeeCup:
        return '☕';
    }
  }

  String get label {
    switch (this) {
      case AppreciationBadge.lily:
        return 'Lily';
      case AppreciationBadge.cookies:
        return 'Cookies';
      case AppreciationBadge.cupcake:
        return 'Cupcake';
      case AppreciationBadge.necklace:
        return 'Necklace';
      case AppreciationBadge.ring:
        return 'Ring';
      case AppreciationBadge.sunshine:
        return 'Sunshine';
      case AppreciationBadge.star:
        return 'Star';
      case AppreciationBadge.book:
        return 'Book';
      case AppreciationBadge.musicNote:
        return 'Music';
      case AppreciationBadge.coffeeCup:
        return 'Coffee';
    }
  }
}

class AppreciationModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? toUserId;
  final String? toUserName;
  final String appreciationText;
  final String winText;
  final List<String> gratitudes;
  final AppreciationBadge selectedBadge;
  final DateTime weekOf;
  final DateTime sentAt;
  final DateTime? viewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppreciationModel({
    String? id,
    required this.fromUserId,
    required this.fromUserName,
    this.toUserId,
    this.toUserName,
    required this.appreciationText,
    required this.winText,
    required this.gratitudes,
    required this.selectedBadge,
    DateTime? weekOf,
    DateTime? sentAt,
    this.viewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        weekOf = weekOf ?? _getWeekOf(DateTime.now()),
        sentAt = sentAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static DateTime _getWeekOf(DateTime date) {
    final weekday = date.weekday;
    final startOfWeek = date.subtract(Duration(days: weekday - 1));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }

  Map<String, dynamic> toJson({String? coupleId}) => {
        'id': id,
        if (coupleId != null) 'couple_id': coupleId,
        'from_user_id': fromUserId,
        'from_user_name': fromUserName,
        'to_user_id': toUserId,
        'to_user_name': toUserName,
        'appreciation_text': appreciationText,
        'win_text': winText,
        'gratitudes': gratitudes,
        'selected_badge': selectedBadge.name,
        'week_of': weekOf.toIso8601String(),
        'sent_at': sentAt.toIso8601String(),
        'viewed_at': viewedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory AppreciationModel.fromJson(Map<String, dynamic> json) {
    final badgeName = (json['selected_badge'] ?? json['selectedBadge'] as String?) ?? AppreciationBadge.star.name;
    final badge = AppreciationBadge.values.firstWhere(
      (b) => b.name == badgeName,
      orElse: () => AppreciationBadge.star,
    );

    return AppreciationModel(
      id: (json['id'] as String?) ?? const Uuid().v4(),
      fromUserId: (json['from_user_id'] ?? json['fromUserId'] as String?) ?? '',
      fromUserName: (json['from_user_name'] ?? json['fromUserName'] as String?) ?? 'Someone',
      toUserId: (json['to_user_id'] ?? json['toUserId']) as String?,
      toUserName: (json['to_user_name'] ?? json['toUserName']) as String?,
      appreciationText: (json['appreciation_text'] ?? json['appreciationText'] as String?) ?? '',
      winText: (json['win_text'] ?? json['winText'] as String?) ?? '',
      gratitudes: (json['gratitudes'] as List?)?.whereType<String>().toList() ?? const [],
      selectedBadge: badge,
      weekOf: DateTime.tryParse((json['week_of'] ?? json['weekOf'] as String?) ?? '') ?? DateTime.now(),
      sentAt: DateTime.tryParse((json['sent_at'] ?? json['sentAt'] as String?) ?? '') ?? DateTime.now(),
      viewedAt: (json['viewed_at'] ?? json['viewedAt']) == null ? null : DateTime.tryParse((json['viewed_at'] ?? json['viewedAt']) as String),
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] as String?) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  AppreciationModel copyWith({
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    String? appreciationText,
    String? winText,
    List<String>? gratitudes,
    AppreciationBadge? selectedBadge,
    DateTime? weekOf,
    DateTime? sentAt,
    DateTime? viewedAt,
  }) =>
      AppreciationModel(
        id: id,
        fromUserId: fromUserId ?? this.fromUserId,
        fromUserName: fromUserName ?? this.fromUserName,
        toUserId: toUserId ?? this.toUserId,
        toUserName: toUserName ?? this.toUserName,
        appreciationText: appreciationText ?? this.appreciationText,
        winText: winText ?? this.winText,
        gratitudes: gratitudes ?? this.gratitudes,
        selectedBadge: selectedBadge ?? this.selectedBadge,
        weekOf: weekOf ?? this.weekOf,
        sentAt: sentAt ?? this.sentAt,
        viewedAt: viewedAt ?? this.viewedAt,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
