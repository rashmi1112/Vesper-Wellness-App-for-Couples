import 'package:uuid/uuid.dart';

enum ChallengeComplexity { easy, medium, hard }

enum ChallengeStatus { notStarted, inProgress, completed, abandoned }

class GrowthChallengeModel {
  final String id;
  final String title;
  final String why;
  final String howToHelp;
  final ChallengeComplexity complexity;
  final String setByUserId;
  final String setByUserName;
  final String assignedToUserId;
  final String assignedToUserName;
  final DateTime startDate;
  final DateTime targetDate;
  final ChallengeStatus status;
  final List<String> checkInNotes;
  final List<String> photoUrls;
  final int progressPercent;
  final DateTime createdAt;
  final DateTime updatedAt;

  GrowthChallengeModel({
    String? id,
    required this.title,
    required this.why,
    required this.howToHelp,
    required this.complexity,
    required this.setByUserId,
    required this.setByUserName,
    required this.assignedToUserId,
    required this.assignedToUserName,
    DateTime? startDate,
    DateTime? targetDate,
    this.status = ChallengeStatus.notStarted,
    this.checkInNotes = const [],
    this.photoUrls = const [],
    this.progressPercent = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now(),
        targetDate = targetDate ?? DateTime.now().add(const Duration(days: 30)),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isActive => status == ChallengeStatus.inProgress;
  
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(targetDate)) return 0;
    return targetDate.difference(now).inDays;
  }

  String get complexityLabel {
    switch (complexity) {
      case ChallengeComplexity.easy:
        return 'Easy';
      case ChallengeComplexity.medium:
        return 'Medium';
      case ChallengeComplexity.hard:
        return 'Hard';
    }
  }

  String get statusLabel {
    switch (status) {
      case ChallengeStatus.notStarted:
        return 'Not Started';
      case ChallengeStatus.inProgress:
        return 'In Progress';
      case ChallengeStatus.completed:
        return 'Completed';
      case ChallengeStatus.abandoned:
        return 'Abandoned';
    }
  }

  Map<String, dynamic> toJson({String? coupleId}) => {
        'id': id,
        if (coupleId != null) 'couple_id': coupleId,
        'title': title,
        'why': why,
        'how_to_help': howToHelp,
        'complexity': complexity.name,
        'set_by_user_id': setByUserId,
        'set_by_user_name': setByUserName,
        'assigned_to_user_id': assignedToUserId,
        'assigned_to_user_name': assignedToUserName,
        'start_date': startDate.toIso8601String(),
        'target_date': targetDate.toIso8601String(),
        'status': status.name,
        'check_in_notes': checkInNotes,
        'photo_urls': photoUrls,
        'progress_percent': progressPercent,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory GrowthChallengeModel.fromJson(Map<String, dynamic> json) {
    final complexityName = (json['complexity'] as String?) ?? ChallengeComplexity.medium.name;
    final complexity = ChallengeComplexity.values.firstWhere(
      (c) => c.name == complexityName,
      orElse: () => ChallengeComplexity.medium,
    );

    final statusName = (json['status'] as String?) ?? ChallengeStatus.notStarted.name;
    final status = ChallengeStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => ChallengeStatus.notStarted,
    );

    return GrowthChallengeModel(
      id: (json['id'] as String?) ?? const Uuid().v4(),
      title: (json['title'] as String?) ?? '',
      why: (json['why'] as String?) ?? '',
      howToHelp: (json['how_to_help'] as String?) ?? (json['howToHelp'] as String?) ?? '',
      complexity: complexity,
      setByUserId: (json['set_by_user_id'] as String?) ?? (json['setByUserId'] as String?) ?? '',
      setByUserName: (json['set_by_user_name'] as String?) ?? (json['setByUserName'] as String?) ?? '',
      assignedToUserId: (json['assigned_to_user_id'] as String?) ?? (json['assignedToUserId'] as String?) ?? '',
      assignedToUserName: (json['assigned_to_user_name'] as String?) ?? (json['assignedToUserName'] as String?) ?? '',
      startDate: DateTime.tryParse((json['start_date'] as String?) ?? (json['startDate'] as String?) ?? '') ?? DateTime.now(),
      targetDate: DateTime.tryParse((json['target_date'] as String?) ?? (json['targetDate'] as String?) ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      status: status,
      checkInNotes: (json['check_in_notes'] as List?)?.whereType<String>().toList() ?? (json['checkInNotes'] as List?)?.whereType<String>().toList() ?? const [],
      photoUrls: (json['photo_urls'] as List?)?.whereType<String>().toList() ?? (json['photoUrls'] as List?)?.whereType<String>().toList() ?? const [],
      progressPercent: (json['progress_percent'] as int?) ?? (json['progressPercent'] as int?) ?? 0,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? (json['createdAt'] as String?) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] as String?) ?? (json['updatedAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  GrowthChallengeModel copyWith({
    String? title,
    String? why,
    String? howToHelp,
    ChallengeComplexity? complexity,
    String? setByUserId,
    String? setByUserName,
    String? assignedToUserId,
    String? assignedToUserName,
    DateTime? startDate,
    DateTime? targetDate,
    ChallengeStatus? status,
    List<String>? checkInNotes,
    List<String>? photoUrls,
    int? progressPercent,
  }) =>
      GrowthChallengeModel(
        id: id,
        title: title ?? this.title,
        why: why ?? this.why,
        howToHelp: howToHelp ?? this.howToHelp,
        complexity: complexity ?? this.complexity,
        setByUserId: setByUserId ?? this.setByUserId,
        setByUserName: setByUserName ?? this.setByUserName,
        assignedToUserId: assignedToUserId ?? this.assignedToUserId,
        assignedToUserName: assignedToUserName ?? this.assignedToUserName,
        startDate: startDate ?? this.startDate,
        targetDate: targetDate ?? this.targetDate,
        status: status ?? this.status,
        checkInNotes: checkInNotes ?? this.checkInNotes,
        photoUrls: photoUrls ?? this.photoUrls,
        progressPercent: progressPercent ?? this.progressPercent,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
