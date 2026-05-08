import 'package:flutter/foundation.dart';
import 'package:vesper/models/growth_challenge_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/services/user_service.dart';

class GrowthChallengeService extends ChangeNotifier {
  bool _isLoading = false;
  List<GrowthChallengeModel> _challenges = [];
  String? _currentUserId;
  String? _coupleId;
  UserService? _userService;

  bool get isLoading => _isLoading;
  List<GrowthChallengeModel> get challenges => List.unmodifiable(_challenges);

  List<GrowthChallengeModel> get activeChallenges =>
      _challenges.where((c) => c.isActive).toList();

  List<GrowthChallengeModel> get completedChallenges =>
      _challenges.where((c) => c.isCompleted).toList();

  int get totalCompleted => completedChallenges.length;
  
  double get completionRate {
    if (_challenges.isEmpty) return 0;
    return (totalCompleted / _challenges.length) * 100;
  }

  int get currentStreak {
    int streak = 0;
    final sorted = List<GrowthChallengeModel>.from(_challenges)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    for (final challenge in sorted) {
      if (challenge.isCompleted) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
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
      await loadChallenges();
    } catch (e) {
      debugPrint('Failed to load growth challenges: $e');
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

  Future<void> loadChallenges() async {
    try {
      if (_currentUserId == null) return;

      // Load challenges for single users (couple_id is null) or couples
      final data = _coupleId != null
          ? await SupabaseService.from('growth_challenges')
              .select()
              .eq('couple_id', _coupleId!)
              .order('created_at', ascending: false)
          : await SupabaseService.from('growth_challenges')
              .select()
              .or('set_by_user_id.eq.$_currentUserId,assigned_to_user_id.eq.$_currentUserId')
              .order('created_at', ascending: false);

      _challenges = (data as List).map((json) => GrowthChallengeModel.fromJson(json as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading challenges: $e');
    }
  }

  Future<void> addChallenge(
    GrowthChallengeModel challenge, {
    UserService? userService,
    NotificationService? notificationService,
  }) async {
    try {
      // Pass null for couple_id if user has no partners
      final hasPartners = _userService?.currentUser?.partnerIds.isNotEmpty ?? false;
      final coupleIdToUse = hasPartners ? _coupleId : null;
      debugPrint('Adding challenge: hasPartners=$hasPartners, coupleId=$coupleIdToUse');
      debugPrint('Challenge data: ${challenge.toJson(coupleId: coupleIdToUse)}');
      await SupabaseService.insert('growth_challenges', challenge.toJson(coupleId: coupleIdToUse));
      await loadChallenges();

      // Create growth date reminders if enabled
      if (userService != null && notificationService != null) {
        final assignedUser = await userService.findUserById(challenge.assignedToUserId);
        if (assignedUser != null && assignedUser.growthDateRemindersEnabled) {
          await notificationService.createGrowthDateReminders(
            growthDate: challenge.targetDate,
            userId: challenge.assignedToUserId,
          );
        }

        // Also notify the person who set the challenge
        final setter = await userService.findUserById(challenge.setByUserId);
        if (setter != null && setter.growthDateRemindersEnabled && challenge.setByUserId != challenge.assignedToUserId) {
          await notificationService.createGrowthDateReminders(
            growthDate: challenge.targetDate,
            userId: challenge.setByUserId,
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add challenge: $e');
      rethrow;
    }
  }

  Future<void> updateChallenge(GrowthChallengeModel updated) async {
    try {
      await SupabaseService.update(
        'growth_challenges',
        updated.toJson(),
        filters: {'id': updated.id},
      );
      await loadChallenges();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update challenge: $e');
      rethrow;
    }
  }

  Future<void> deleteChallenge(String id) async {
    try {
      await SupabaseService.delete('growth_challenges', filters: {'id': id});
      await loadChallenges();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete challenge: $e');
    }
  }
}
