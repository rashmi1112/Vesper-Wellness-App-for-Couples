import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserModel {
  final String id;

  // Core identity
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String genderOrientation;
  final String? profilePhotoBase64;

  // Relationship / onboarding
  final String relationshipLength;
  final String relationshipFeeling;
  final List<String> togetherlyGoals;

  // Pairing (poly-friendly)
  final List<String> partnerIds;
  final List<String> outgoingLinkRequests;
  final List<String> incomingLinkRequests;

  // Legacy fields still used in a couple of existing pages
  final String partnerName;
  final DateTime anniversaryDate;

  // Notification preferences
  final bool growthDateRemindersEnabled;
  final bool appreciationPromptsEnabled;
  final String appreciationPromptDay;
  final TimeOfDay appreciationPromptTime;
  final bool peaceLilyNotificationsEnabled;
  final bool pairingNotificationsEnabled;
  final bool weeklyDigestEnabled;
  final bool streakCelebrationEnabled;

  // Couple settings
  final int growthDateDayOfMonth;
  final String appreciationFrequency;
  final bool fightBetterEnabled;
  final bool growTogetherEnabled;
  final bool loveOutLoudEnabled;

  // Local auth
  final String? passwordSalt;
  final String? passwordHash;
  final bool biometricEnabled;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    String? id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.genderOrientation,
    required this.relationshipLength,
    required this.relationshipFeeling,
    required this.togetherlyGoals,
    this.profilePhotoBase64,
    this.partnerIds = const [],
    this.outgoingLinkRequests = const [],
    this.incomingLinkRequests = const [],
    this.partnerName = '',
    DateTime? anniversaryDate,
    this.growthDateRemindersEnabled = true,
    this.appreciationPromptsEnabled = true,
    this.appreciationPromptDay = 'Sunday',
    this.appreciationPromptTime = const TimeOfDay(hour: 18, minute: 0),
    this.peaceLilyNotificationsEnabled = true,
    this.pairingNotificationsEnabled = true,
    this.weeklyDigestEnabled = false,
    this.streakCelebrationEnabled = true,
    this.growthDateDayOfMonth = 1,
    this.appreciationFrequency = 'Weekly',
    this.fightBetterEnabled = true,
    this.growTogetherEnabled = true,
    this.loveOutLoudEnabled = true,
    this.passwordSalt,
    this.passwordHash,
    this.biometricEnabled = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        anniversaryDate = anniversaryDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'gender_orientation': genderOrientation,
        'profile_photo_base64': profilePhotoBase64,
        'relationship_length': relationshipLength,
        'relationship_feeling': relationshipFeeling,
        'togetherly_goals': togetherlyGoals,
        'partner_ids': partnerIds,
        'outgoing_link_requests': outgoingLinkRequests,
        'incoming_link_requests': incomingLinkRequests,
        'partner_name': partnerName,
        'anniversary_date': anniversaryDate.toIso8601String(),
        'growth_date_reminders_enabled': growthDateRemindersEnabled,
        'appreciation_prompts_enabled': appreciationPromptsEnabled,
        'appreciation_prompt_day': appreciationPromptDay,
        'appreciation_prompt_time': '${appreciationPromptTime.hour}:${appreciationPromptTime.minute}',
        'peace_lily_notifications_enabled': peaceLilyNotificationsEnabled,
        'pairing_notifications_enabled': pairingNotificationsEnabled,
        'weekly_digest_enabled': weeklyDigestEnabled,
        'streak_celebration_enabled': streakCelebrationEnabled,
        'growth_date_day_of_month': growthDateDayOfMonth,
        'appreciation_frequency': appreciationFrequency,
        'fight_better_enabled': fightBetterEnabled,
        'grow_together_enabled': growTogetherEnabled,
        'love_out_loud_enabled': loveOutLoudEnabled,
        'password_salt': passwordSalt,
        'password_hash': passwordHash,
        'biometric_enabled': biometricEnabled,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Support both snake_case (database) and camelCase (legacy) keys
    final name = (json['name'] as String?) ?? 'You';
    final partnerName = (json['partner_name'] ?? json['partnerName'] as String?) ?? '';
    final anniversary = (json['anniversary_date'] ?? json['anniversaryDate']) != null
        ? DateTime.tryParse((json['anniversary_date'] ?? json['anniversaryDate']) as String) ?? DateTime.now()
        : DateTime.now();

    TimeOfDay parseTime(String? timeStr) {
      if (timeStr == null) return const TimeOfDay(hour: 18, minute: 0);
      final parts = timeStr.split(':');
      if (parts.length != 2) return const TimeOfDay(hour: 18, minute: 0);
      return TimeOfDay(hour: int.tryParse(parts[0]) ?? 18, minute: int.tryParse(parts[1]) ?? 0);
    }

    return UserModel(
      id: (json['id'] as String?) ?? const Uuid().v4(),
      name: name,
      email: (json['email'] as String?) ?? '',
      phoneNumber: (json['phone_number'] ?? json['phoneNumber'] as String?) ?? '',
      dateOfBirth: DateTime.tryParse((json['date_of_birth'] ?? json['dateOfBirth'] as String?) ?? '') ?? DateTime(2000, 1, 1),
      genderOrientation: (json['gender_orientation'] ?? json['genderOrientation'] as String?) ?? 'Prefer not to say',
      profilePhotoBase64: (json['profile_photo_base64'] ?? json['profilePhotoBase64']) as String?,
      relationshipLength: (json['relationship_length'] ?? json['relationshipLength'] as String?) ?? 'Less than 1 year',
      relationshipFeeling: (json['relationship_feeling'] ?? json['relationshipFeeling'] as String?) ?? 'Good',
      togetherlyGoals: ((json['togetherly_goals'] ?? json['togetherlyGoals']) as List?)?.whereType<String>().toList() ?? const [],
      partnerIds: ((json['partner_ids'] ?? json['partnerIds']) as List?)?.whereType<String>().toList() ?? const [],
      outgoingLinkRequests: ((json['outgoing_link_requests'] ?? json['outgoingLinkRequests']) as List?)?.whereType<String>().toList() ?? const [],
      incomingLinkRequests: ((json['incoming_link_requests'] ?? json['incomingLinkRequests']) as List?)?.whereType<String>().toList() ?? const [],
      partnerName: partnerName,
      anniversaryDate: anniversary,
      growthDateRemindersEnabled: (json['growth_date_reminders_enabled'] ?? json['growthDateRemindersEnabled'] as bool?) ?? true,
      appreciationPromptsEnabled: (json['appreciation_prompts_enabled'] ?? json['appreciationPromptsEnabled'] as bool?) ?? true,
      appreciationPromptDay: (json['appreciation_prompt_day'] ?? json['appreciationPromptDay'] as String?) ?? 'Sunday',
      appreciationPromptTime: parseTime((json['appreciation_prompt_time'] ?? json['appreciationPromptTime']) as String?),
      peaceLilyNotificationsEnabled: (json['peace_lily_notifications_enabled'] ?? json['peaceLilyNotificationsEnabled'] as bool?) ?? true,
      pairingNotificationsEnabled: (json['pairing_notifications_enabled'] ?? json['pairingNotificationsEnabled'] as bool?) ?? true,
      weeklyDigestEnabled: (json['weekly_digest_enabled'] ?? json['weeklyDigestEnabled'] as bool?) ?? false,
      streakCelebrationEnabled: (json['streak_celebration_enabled'] ?? json['streakCelebrationEnabled'] as bool?) ?? true,
      growthDateDayOfMonth: (json['growth_date_day_of_month'] ?? json['growthDateDayOfMonth'] as int?) ?? 1,
      appreciationFrequency: (json['appreciation_frequency'] ?? json['appreciationFrequency'] as String?) ?? 'Weekly',
      fightBetterEnabled: (json['fight_better_enabled'] ?? json['fightBetterEnabled'] as bool?) ?? true,
      growTogetherEnabled: (json['grow_together_enabled'] ?? json['growTogetherEnabled'] as bool?) ?? true,
      loveOutLoudEnabled: (json['love_out_loud_enabled'] ?? json['loveOutLoudEnabled'] as bool?) ?? true,
      passwordSalt: (json['password_salt'] ?? json['passwordSalt']) as String?,
      passwordHash: (json['password_hash'] ?? json['passwordHash']) as String?,
      biometricEnabled: (json['biometric_enabled'] ?? json['biometricEnabled'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] as String?) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? genderOrientation,
    String? profilePhotoBase64,
    String? relationshipLength,
    String? relationshipFeeling,
    List<String>? togetherlyGoals,
    List<String>? partnerIds,
    List<String>? outgoingLinkRequests,
    List<String>? incomingLinkRequests,
    String? partnerName,
    DateTime? anniversaryDate,
    bool? growthDateRemindersEnabled,
    bool? appreciationPromptsEnabled,
    String? appreciationPromptDay,
    TimeOfDay? appreciationPromptTime,
    bool? peaceLilyNotificationsEnabled,
    bool? pairingNotificationsEnabled,
    bool? weeklyDigestEnabled,
    bool? streakCelebrationEnabled,
    int? growthDateDayOfMonth,
    String? appreciationFrequency,
    bool? fightBetterEnabled,
    bool? growTogetherEnabled,
    bool? loveOutLoudEnabled,
    String? passwordSalt,
    String? passwordHash,
    bool? biometricEnabled,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        genderOrientation: genderOrientation ?? this.genderOrientation,
        profilePhotoBase64: profilePhotoBase64 ?? this.profilePhotoBase64,
        relationshipLength: relationshipLength ?? this.relationshipLength,
        relationshipFeeling: relationshipFeeling ?? this.relationshipFeeling,
        togetherlyGoals: togetherlyGoals ?? this.togetherlyGoals,
        partnerIds: partnerIds ?? this.partnerIds,
        outgoingLinkRequests: outgoingLinkRequests ?? this.outgoingLinkRequests,
        incomingLinkRequests: incomingLinkRequests ?? this.incomingLinkRequests,
        partnerName: partnerName ?? this.partnerName,
        anniversaryDate: anniversaryDate ?? this.anniversaryDate,
        growthDateRemindersEnabled: growthDateRemindersEnabled ?? this.growthDateRemindersEnabled,
        appreciationPromptsEnabled: appreciationPromptsEnabled ?? this.appreciationPromptsEnabled,
        appreciationPromptDay: appreciationPromptDay ?? this.appreciationPromptDay,
        appreciationPromptTime: appreciationPromptTime ?? this.appreciationPromptTime,
        peaceLilyNotificationsEnabled: peaceLilyNotificationsEnabled ?? this.peaceLilyNotificationsEnabled,
        pairingNotificationsEnabled: pairingNotificationsEnabled ?? this.pairingNotificationsEnabled,
        weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
        streakCelebrationEnabled: streakCelebrationEnabled ?? this.streakCelebrationEnabled,
        growthDateDayOfMonth: growthDateDayOfMonth ?? this.growthDateDayOfMonth,
        appreciationFrequency: appreciationFrequency ?? this.appreciationFrequency,
        fightBetterEnabled: fightBetterEnabled ?? this.fightBetterEnabled,
        growTogetherEnabled: growTogetherEnabled ?? this.growTogetherEnabled,
        loveOutLoudEnabled: loveOutLoudEnabled ?? this.loveOutLoudEnabled,
        passwordSalt: passwordSalt ?? this.passwordSalt,
        passwordHash: passwordHash ?? this.passwordHash,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
