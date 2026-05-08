import 'package:flutter/foundation.dart';
import 'package:vesper/models/milestone_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/services/user_service.dart';

class MilestoneService extends ChangeNotifier {
  List<MilestoneModel> _milestones = [];
  bool _isLoading = false;
  String? _currentUserId;
  String? _coupleId;
  UserService? _userService;

  List<MilestoneModel> get milestones => List.unmodifiable(_milestones);
  bool get isLoading => _isLoading;

  List<MilestoneModel> get upcomingMilestones {
    final sorted = List<MilestoneModel>.from(_milestones)
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return sorted.where((m) => m.daysUntil >= 0).take(3).toList();
  }

  MilestoneModel? get nextMilestone {
    if (_milestones.isEmpty) return null;
    final sorted = List<MilestoneModel>.from(_milestones)
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return sorted.firstWhere((m) => m.daysUntil >= 0, orElse: () => sorted.first);
  }

  int get totalMilestones => _milestones.length;

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
      await loadMilestones();
    } catch (e) {
      debugPrint('Error loading milestones: $e');
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

  Future<void> loadMilestones() async {
    try {
      if (_coupleId == null) return;

      final data = await SupabaseService.select(
        'milestones',
        filters: {'couple_id': _coupleId},
      );

      _milestones = data.map((json) => MilestoneModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading milestones: $e');
    }
  }

  Future<void> addMilestone(MilestoneModel milestone) async {
    try {
      if (_coupleId == null) return;

      await SupabaseService.insert('milestones', milestone.toJson(coupleId: _coupleId));
      await loadMilestones();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding milestone: $e');
    }
  }

  Future<void> updateMilestone(MilestoneModel milestone) async {
    try {
      if (_coupleId == null) return;

      await SupabaseService.update(
        'milestones',
        milestone.toJson(coupleId: _coupleId),
        filters: {'id': milestone.id},
      );
      await loadMilestones();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating milestone: $e');
    }
  }

  Future<void> deleteMilestone(String id) async {
    try {
      await SupabaseService.delete('milestones', filters: {'id': id});
      await loadMilestones();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting milestone: $e');
    }
  }
}
