import 'package:flutter/foundation.dart';
import 'package:vesper/models/in_app_notification_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/models/user_model.dart';

class NotificationService extends ChangeNotifier {
  bool _isLoading = false;
  List<InAppNotificationModel> _items = [];
  String? _currentUserId;

  bool get isLoading => _isLoading;
  List<InAppNotificationModel> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    _currentUserId = SupabaseConfig.auth.currentUser?.id;
    if (_currentUserId == null) {
      _isLoading = false;
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await loadNotifications();
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNotifications() async {
    try {
      if (_currentUserId == null) return;

      final data = await SupabaseService.select(
        'in_app_notifications',
        filters: {'user_id': _currentUserId},
        orderBy: 'created_at',
        ascending: false,
      );

      _items = data.map((json) => InAppNotificationModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> add(InAppNotificationModel notification) async {
    try {
      if (_currentUserId == null) return;

      await SupabaseService.insert('in_app_notifications', notification.toJson());
      await loadNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add notification: $e');
    }
  }

  Future<void> markRead(String id, {required bool isRead}) async {
    try {
      await SupabaseService.update(
        'in_app_notifications',
        {'is_read': isRead},
        filters: {'id': id},
      );
      await loadNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark notification read: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      if (_currentUserId == null) return;

      for (final item in _items.where((n) => !n.isRead)) {
        await SupabaseService.update(
          'in_app_notifications',
          {'is_read': true},
          filters: {'id': item.id},
        );
      }
      await loadNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark all notifications read: $e');
    }
  }

  Future<void> clear() async {
    try {
      if (_currentUserId == null) return;

      for (final item in _items) {
        await SupabaseService.delete('in_app_notifications', filters: {'id': item.id});
      }
      await loadNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear notifications: $e');
    }
  }

  // ============ AUTOMATIC NOTIFICATION CREATION ============

  /// Creates growth date reminder notifications (10 days before, 3 days before, and day of)
  Future<void> createGrowthDateReminders({
    required DateTime growthDate,
    required String userId,
  }) async {
    try {
      final notifications = <InAppNotificationModel>[
        InAppNotificationModel(
          type: InAppNotificationType.growthReminder,
          title: '🌱 Growth Date in 10 Days!',
          body: 'Your monthly growth date is coming up on ${_formatDate(growthDate)}. Start thinking about what you want to work on together!',
          payload: {'date': growthDate.toIso8601String(), 'daysUntil': '10'},
        ),
        InAppNotificationModel(
          type: InAppNotificationType.growthReminder,
          title: '🌱 Growth Date in 3 Days',
          body: 'Your growth date is this ${_getDayName(growthDate)}! Don\'t forget to set aside quality time.',
          payload: {'date': growthDate.toIso8601String(), 'daysUntil': '3'},
        ),
        InAppNotificationModel(
          type: InAppNotificationType.growthReminder,
          title: '🌱 Growth Date Today!',
          body: 'Today is your growth date! Take time to connect and grow together.',
          payload: {'date': growthDate.toIso8601String(), 'daysUntil': '0'},
        ),
      ];

      for (final notification in notifications) {
        await SupabaseService.insert('in_app_notifications', {
          ...notification.toJson(),
          'user_id': userId,
        });
      }
      
      debugPrint('Created ${notifications.length} growth date reminders for $userId');
    } catch (e) {
      debugPrint('Failed to create growth date reminders: $e');
    }
  }

  /// Creates appreciation prompt notification
  Future<void> createAppreciationPrompt({
    required String userId,
    required String partnerName,
  }) async {
    try {
      final notification = InAppNotificationModel(
        type: InAppNotificationType.appreciationPrompt,
        title: '💝 Time to Love Out Loud!',
        body: 'Share what you appreciate about $partnerName, celebrate your wins, and reflect on your gratitude.',
        payload: {'promptType': 'weekly'},
      );

      await SupabaseService.insert('in_app_notifications', {
        ...notification.toJson(),
        'user_id': userId,
      });
      
      debugPrint('Created appreciation prompt for $userId');
    } catch (e) {
      debugPrint('Failed to create appreciation prompt: $e');
    }
  }

  /// Creates peace lily received notification
  Future<void> createPeaceLilyNotification({
    required String recipientUserId,
    required String senderName,
    String? sessionId,
  }) async {
    try {
      final notification = InAppNotificationModel(
        type: InAppNotificationType.peaceLilyReceived,
        title: '🌸 Peace Lily from $senderName',
        body: '$senderName sent you a gentle signal: "I\'m ready to connect when you are."',
        payload: {
          'senderName': senderName,
          if (sessionId != null) 'sessionId': sessionId,
        },
      );

      await SupabaseService.insert('in_app_notifications', {
        ...notification.toJson(),
        'user_id': recipientUserId,
      });
      
      debugPrint('Created peace lily notification for $recipientUserId from $senderName');
    } catch (e) {
      debugPrint('Failed to create peace lily notification: $e');
    }
  }

  /// Creates partner accepted pairing notification
  Future<void> createPairingAcceptedNotification({
    required String userId,
    required String partnerName,
  }) async {
    try {
      final notification = InAppNotificationModel(
        type: InAppNotificationType.partnerAcceptedPairing,
        title: '🎉 $partnerName Accepted!',
        body: '$partnerName accepted your pairing request! You can now start your journey together.',
        payload: {'partnerName': partnerName},
      );

      await SupabaseService.insert('in_app_notifications', {
        ...notification.toJson(),
        'user_id': userId,
      });
      
      debugPrint('Created pairing accepted notification for $userId');
    } catch (e) {
      debugPrint('Failed to create pairing accepted notification: $e');
    }
  }

  /// Creates partner check-in completed notification (for weekly digest)
  Future<void> createCheckInCompletedNotification({
    required String userId,
    required String partnerName,
    required String mood,
    required int connectionScore,
  }) async {
    try {
      final notification = InAppNotificationModel(
        type: InAppNotificationType.weeklyDigest,
        title: '💭 $partnerName Checked In',
        body: '$partnerName shared their mood and gave a connection score of $connectionScore/10.',
        payload: {
          'partnerName': partnerName,
          'mood': mood,
          'connectionScore': connectionScore.toString(),
        },
      );

      await SupabaseService.insert('in_app_notifications', {
        ...notification.toJson(),
        'user_id': userId,
      });
      
      debugPrint('Created check-in completed notification for $userId');
    } catch (e) {
      debugPrint('Failed to create check-in completed notification: $e');
    }
  }

  /// Creates streak celebration notification
  Future<void> createStreakCelebrationNotification({
    required String userId,
    required String partnerName,
    required int weeksStreak,
  }) async {
    try {
      final notification = InAppNotificationModel(
        type: InAppNotificationType.streakCelebration,
        title: '🔥 $weeksStreak Week Streak!',
        body: 'You and $partnerName both completed your appreciation this week! Keep the momentum going!',
        payload: {
          'partnerName': partnerName,
          'weeksStreak': weeksStreak.toString(),
        },
      );

      await SupabaseService.insert('in_app_notifications', {
        ...notification.toJson(),
        'user_id': userId,
      });
      
      debugPrint('Created streak celebration notification for $userId');
    } catch (e) {
      debugPrint('Failed to create streak celebration notification: $e');
    }
  }

  // Helper methods
  String _formatDate(DateTime date) => '${_monthName(date.month)} ${date.day}';
  
  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
  
  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}
