import 'package:flutter/foundation.dart';
import 'package:vesper/models/check_in_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/services/user_service.dart';

class CheckInService extends ChangeNotifier {
  List<CheckInModel> _checkIns = [];
  bool _isLoading = false;
  String? _currentUserId;
  String? _coupleId;
  UserService? _userService;

  List<CheckInModel> get checkIns => List.unmodifiable(_checkIns);
  bool get isLoading => _isLoading;

  CheckInModel? get todayCheckIn {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _checkIns.where((c) {
      final checkInDate = DateTime(c.date.year, c.date.month, c.date.day);
      return checkInDate.isAtSameMomentAs(today) && !c.isPartner;
    }).firstOrNull;
  }

  double get averageConnectionScore {
    if (_checkIns.isEmpty) return 0;
    final total = _checkIns.fold<int>(0, (sum, c) => sum + c.connectionScore);
    return total / _checkIns.length;
  }

  int get currentStreak {
    if (_checkIns.isEmpty) return 0;
    
    final sortedCheckIns = List<CheckInModel>.from(_checkIns)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    var checkDate = DateTime.now();
    
    for (var checkIn in sortedCheckIns) {
      final checkInDate = DateTime(checkIn.date.year, checkIn.date.month, checkIn.date.day);
      final expectedDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
      
      if (checkInDate.isAtSameMomentAs(expectedDate) || 
          checkInDate.isAtSameMomentAs(expectedDate.subtract(const Duration(days: 1)))) {
        streak++;
        checkDate = checkInDate;
      } else if (checkInDate.isBefore(expectedDate.subtract(const Duration(days: 1)))) {
        break;
      }
    }
    
    return streak;
  }

  List<CheckInModel> get recentCheckIns => _checkIns.take(7).toList();

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
      await loadCheckIns();
    } catch (e) {
      debugPrint('Error loading check-ins: $e');
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

  Future<void> loadCheckIns() async {
    try {
      if (_currentUserId == null || _coupleId == null) return;

      final data = await SupabaseService.select(
        'check_ins',
        filters: {'couple_id': _coupleId, 'user_id': _currentUserId},
        orderBy: 'date',
        ascending: false,
      );

      _checkIns = data.map((json) => CheckInModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading check-ins: $e');
    }
  }

  Future<void> addCheckIn({
    required MoodLevel mood,
    required int connectionScore,
    String? note,
    UserService? userService,
    NotificationService? notificationService,
  }) async {
    try {
      if (_currentUserId == null || _coupleId == null) return;

      final checkIn = CheckInModel(
        date: DateTime.now(),
        mood: mood,
        connectionScore: connectionScore,
        note: note,
      );
      
      await SupabaseService.insert('check_ins', checkIn.toJson(coupleId: _coupleId, userId: _currentUserId));
      await loadCheckIns();

      // Notify partners if weekly digest is enabled
      if (userService != null && notificationService != null) {
        final currentUser = userService.currentUser;
        if (currentUser != null && currentUser.partnerIds.isNotEmpty) {
          for (final partnerId in currentUser.partnerIds) {
            final partner = await userService.findUserById(partnerId);
            if (partner != null && partner.weeklyDigestEnabled) {
              await notificationService.createCheckInCompletedNotification(
                userId: partnerId,
                partnerName: currentUser.name,
                mood: mood.name,
                connectionScore: connectionScore,
              );
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding check-in: $e');
    }
  }

  Future<void> deleteCheckIn(String id) async {
    try {
      await SupabaseService.delete('check_ins', filters: {'id': id});
      await loadCheckIns();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting check-in: $e');
    }
  }
}
