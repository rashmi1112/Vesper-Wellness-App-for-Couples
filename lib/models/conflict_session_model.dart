import 'package:uuid/uuid.dart';

enum ConflictReadiness {
  initiateNow,
  notYet,
  wantPartnerToReachOut,
}

enum ConflictPartnerResponse {
  none,
  readyToo,
  needsMoreTime,
}

class ConflictSessionModel {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;

  final bool breathingSkipped;

  final List<String> emotions;
  final String emotionFreeText;

  final String triggerText;
  final bool connectedToPastPattern;
  final String pastPatternText;

  final List<String> needs;

  final ConflictReadiness readiness;
  final ConflictPartnerResponse partnerResponse;

  final String conversationNotes;

  final int? resolutionRating; // 1-5
  final String resolutionNotes;

  final bool aiSummaryEnabled;
  final String aiSummaryText;

  final int? followUpInDays;

  final DateTime createdAt;
  final DateTime updatedAt;

  ConflictSessionModel({
    String? id,
    DateTime? startedAt,
    this.endedAt,
    this.breathingSkipped = false,
    this.emotions = const [],
    this.emotionFreeText = '',
    this.triggerText = '',
    this.connectedToPastPattern = false,
    this.pastPatternText = '',
    this.needs = const [],
    this.readiness = ConflictReadiness.notYet,
    this.partnerResponse = ConflictPartnerResponse.none,
    this.conversationNotes = '',
    this.resolutionRating,
    this.resolutionNotes = '',
    this.aiSummaryEnabled = false,
    this.aiSummaryText = '',
    this.followUpInDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        startedAt = startedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);

  bool get isResolved => endedAt != null;

  Map<String, dynamic> toJson({String? coupleId, String? initiatorId}) => {
        'id': id,
        if (coupleId != null) 'couple_id': coupleId,
        if (initiatorId != null) 'initiator_id': initiatorId,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'breathing_skipped': breathingSkipped,
        'emotions': emotions,
        'emotion_free_text': emotionFreeText,
        'trigger_text': triggerText,
        'connected_to_past_pattern': connectedToPastPattern,
        'past_pattern_text': pastPatternText,
        'needs': needs,
        'readiness': readiness.name,
        'partner_response': partnerResponse.name,
        'conversation_notes': conversationNotes,
        'resolution_rating': resolutionRating,
        'resolution_notes': resolutionNotes,
        'ai_summary_enabled': aiSummaryEnabled,
        'ai_summary_text': aiSummaryText,
        'follow_up_in_days': followUpInDays,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ConflictSessionModel.fromJson(Map<String, dynamic> json) {
    ConflictReadiness parseReadiness() {
      final name = (json['readiness'] as String?) ?? ConflictReadiness.notYet.name;
      return ConflictReadiness.values.firstWhere((e) => e.name == name, orElse: () => ConflictReadiness.notYet);
    }

    ConflictPartnerResponse parsePartnerResponse() {
      final name = (json['partner_response'] ?? json['partnerResponse'] as String?) ?? ConflictPartnerResponse.none.name;
      return ConflictPartnerResponse.values.firstWhere((e) => e.name == name, orElse: () => ConflictPartnerResponse.none);
    }

    return ConflictSessionModel(
      id: (json['id'] as String?) ?? const Uuid().v4(),
      startedAt: DateTime.tryParse((json['started_at'] ?? json['startedAt'] as String?) ?? '') ?? DateTime.now(),
      endedAt: (json['ended_at'] ?? json['endedAt']) != null ? DateTime.tryParse((json['ended_at'] ?? json['endedAt']) as String) : null,
      breathingSkipped: (json['breathing_skipped'] ?? json['breathingSkipped'] as bool?) ?? false,
      emotions: (json['emotions'] as List?)?.whereType<String>().toList() ?? const [],
      emotionFreeText: (json['emotion_free_text'] ?? json['emotionFreeText'] as String?) ?? '',
      triggerText: (json['trigger_text'] ?? json['triggerText'] as String?) ?? '',
      connectedToPastPattern: (json['connected_to_past_pattern'] ?? json['connectedToPastPattern'] as bool?) ?? false,
      pastPatternText: (json['past_pattern_text'] ?? json['pastPatternText'] as String?) ?? '',
      needs: (json['needs'] as List?)?.whereType<String>().toList() ?? const [],
      readiness: parseReadiness(),
      partnerResponse: parsePartnerResponse(),
      conversationNotes: (json['conversation_notes'] ?? json['conversationNotes'] as String?) ?? '',
      resolutionRating: (json['resolution_rating'] ?? json['resolutionRating']) as int?,
      resolutionNotes: (json['resolution_notes'] ?? json['resolutionNotes'] as String?) ?? '',
      aiSummaryEnabled: (json['ai_summary_enabled'] ?? json['aiSummaryEnabled'] as bool?) ?? false,
      aiSummaryText: (json['ai_summary_text'] ?? json['aiSummaryText'] as String?) ?? '',
      followUpInDays: (json['follow_up_in_days'] ?? json['followUpInDays']) as int?,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] as String?) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  ConflictSessionModel copyWith({
    DateTime? startedAt,
    DateTime? endedAt,
    bool? breathingSkipped,
    List<String>? emotions,
    String? emotionFreeText,
    String? triggerText,
    bool? connectedToPastPattern,
    String? pastPatternText,
    List<String>? needs,
    ConflictReadiness? readiness,
    ConflictPartnerResponse? partnerResponse,
    String? conversationNotes,
    int? resolutionRating,
    String? resolutionNotes,
    bool? aiSummaryEnabled,
    String? aiSummaryText,
    int? followUpInDays,
  }) =>
      ConflictSessionModel(
        id: id,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        breathingSkipped: breathingSkipped ?? this.breathingSkipped,
        emotions: emotions ?? this.emotions,
        emotionFreeText: emotionFreeText ?? this.emotionFreeText,
        triggerText: triggerText ?? this.triggerText,
        connectedToPastPattern: connectedToPastPattern ?? this.connectedToPastPattern,
        pastPatternText: pastPatternText ?? this.pastPatternText,
        needs: needs ?? this.needs,
        readiness: readiness ?? this.readiness,
        partnerResponse: partnerResponse ?? this.partnerResponse,
        conversationNotes: conversationNotes ?? this.conversationNotes,
        resolutionRating: resolutionRating ?? this.resolutionRating,
        resolutionNotes: resolutionNotes ?? this.resolutionNotes,
        aiSummaryEnabled: aiSummaryEnabled ?? this.aiSummaryEnabled,
        aiSummaryText: aiSummaryText ?? this.aiSummaryText,
        followUpInDays: followUpInDays ?? this.followUpInDays,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
