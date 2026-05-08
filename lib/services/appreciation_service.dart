import 'package:flutter/foundation.dart';
import 'package:vesper/models/appreciation_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/services/user_service.dart';

class AppreciationService extends ChangeNotifier {
  bool _isLoading = false;
  List<AppreciationModel> _entries = [];
  String? _currentUserId;
  String? _coupleId;
  UserService? _userService;

  bool get isLoading => _isLoading;
  List<AppreciationModel> get entries => List.unmodifiable(_entries);

  List<AppreciationModel> sentBy(String userId) =>
      _entries.where((e) => e.fromUserId == userId).toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

  List<AppreciationModel> receivedBy(String userId) =>
      _entries.where((e) => e.toUserId == userId).toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

  int get totalBadgesCollected => _entries.length;

  Map<AppreciationBadge, int> badgesCounts() {
    final counts = <AppreciationBadge, int>{};
    for (final badge in AppreciationBadge.values) {
      counts[badge] = 0;
    }
    for (final entry in _entries) {
      counts[entry.selectedBadge] = (counts[entry.selectedBadge] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> initialize({UserService? userService}) async {
    _userService = userService;
    _currentUserId = SupabaseConfig.auth.currentUser?.id;
    if (_currentUserId == null) {
      _isLoading = false;
      return;
    }

    // Get couple_id from user service
    if (_userService != null && _userService!.currentUser != null) {
      _coupleId = _getCoupleId(_userService!.currentUser!.partnerIds, _currentUserId!);
    }

    _isLoading = true;
    notifyListeners();

    try {
      await loadAppreciations();
    } catch (e) {
      debugPrint('Failed to load appreciations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getCoupleId(List<String> partnerIds, String currentUserId) {
    final allIds = [currentUserId, ...partnerIds];
    allIds.sort();
    return allIds.join('_');
  }

  Future<void> loadAppreciations() async {
    try {
      if (_currentUserId == null || _coupleId == null) return;

      final data = await SupabaseService.from('appreciation_entries')
          .select()
          .eq('couple_id', _coupleId!)
          .order('sent_at', ascending: false);

      _entries = (data as List).map((json) => AppreciationModel.fromJson(json as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading appreciations: $e');
    }
  }

  Future<void> addAppreciation(
    AppreciationModel appreciation, {
    UserService? userService,
    NotificationService? notificationService,
  }) async {
    try {
      await SupabaseService.insert('appreciation_entries', appreciation.toJson());
      await loadAppreciations();

      // Check for streak celebration if both partners completed appreciation this week
      if (userService != null && notificationService != null) {
        final currentUser = userService.currentUser;
        if (currentUser != null && currentUser.partnerIds.isNotEmpty) {
          await _checkAndCelebrateStreak(
            currentUser: currentUser,
            userService: userService,
            notificationService: notificationService,
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add appreciation: $e');
      rethrow;
    }
  }

  Future<void> _checkAndCelebrateStreak({
    required dynamic currentUser,
    required UserService userService,
    required NotificationService notificationService,
  }) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      // Check if current user completed appreciation this week
      final currentUserCompletedThisWeek = _entries.any((entry) =>
          entry.fromUserId == currentUser.id &&
          entry.sentAt.isAfter(startOfWeekMidnight));

      if (!currentUserCompletedThisWeek) return;

      // Check each partner
      for (final partnerId in currentUser.partnerIds) {
        final partner = await userService.findUserById(partnerId);
        if (partner == null || !partner.streakCelebrationEnabled) continue;

        final partnerCompletedThisWeek = _entries.any((entry) =>
            entry.fromUserId == partnerId &&
            entry.sentAt.isAfter(startOfWeekMidnight));

        if (partnerCompletedThisWeek) {
          // Both completed this week - calculate streak
          final streak = _calculateConsecutiveWeeks(currentUser.id, partnerId);
          
          // Create celebration notifications for both
          await notificationService.createStreakCelebrationNotification(
            userId: currentUser.id,
            partnerName: partner.name,
            weeksStreak: streak,
          );
          
          await notificationService.createStreakCelebrationNotification(
            userId: partnerId,
            partnerName: currentUser.name,
            weeksStreak: streak,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to check streak: $e');
    }
  }

  int _calculateConsecutiveWeeks(String userId1, String userId2) {
    int streak = 0;
    var checkDate = DateTime.now();

    for (int i = 0; i < 52; i++) {
      final startOfWeek = checkDate.subtract(Duration(days: checkDate.weekday - 1));
      final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endOfWeek = startOfWeekMidnight.add(const Duration(days: 7));

      final user1Completed = _entries.any((entry) =>
          entry.fromUserId == userId1 &&
          entry.sentAt.isAfter(startOfWeekMidnight) &&
          entry.sentAt.isBefore(endOfWeek));

      final user2Completed = _entries.any((entry) =>
          entry.fromUserId == userId2 &&
          entry.sentAt.isAfter(startOfWeekMidnight) &&
          entry.sentAt.isBefore(endOfWeek));

      if (user1Completed && user2Completed) {
        streak++;
        checkDate = startOfWeekMidnight.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> markViewed(String id) async {
    try {
      await SupabaseService.update(
        'appreciation_entries',
        {'viewed_at': DateTime.now().toIso8601String()},
        filters: {'id': id},
      );
      await loadAppreciations();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark appreciation viewed: $e');
    }
  }
}
