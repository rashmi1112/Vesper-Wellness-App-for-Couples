import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:vesper/models/date_idea_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/services/user_service.dart';

class DateIdeaService extends ChangeNotifier {
  List<DateIdeaModel> _dateIdeas = [];
  bool _isLoading = false;
  String? _currentUserId;
  String? _coupleId;
  UserService? _userService;

  List<DateIdeaModel> get dateIdeas => List.unmodifiable(_dateIdeas);
  bool get isLoading => _isLoading;

  List<DateIdeaModel> get incompleteDateIdeas => 
      _dateIdeas.where((d) => !d.isCompleted).toList();

  List<DateIdeaModel> get completedDateIdeas => 
      _dateIdeas.where((d) => d.isCompleted).toList();

  int get completedCount => completedDateIdeas.length;

  DateIdeaModel? getRandomIdea([DateCategory? category]) {
    final ideas = category != null 
        ? incompleteDateIdeas.where((d) => d.category == category).toList()
        : incompleteDateIdeas;
    if (ideas.isEmpty) return null;
    return ideas[Random().nextInt(ideas.length)];
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
      await loadDateIdeas();
    } catch (e) {
      debugPrint('Error loading date ideas: $e');
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

  Future<void> loadDateIdeas() async {
    try {
      if (_coupleId == null) return;

      final data = await SupabaseService.select(
        'date_ideas',
        filters: {'couple_id': _coupleId},
      );

      _dateIdeas = data.map((json) => DateIdeaModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading date ideas: $e');
    }
  }

  Future<void> markAsCompleted(String id) async {
    try {
      await SupabaseService.update(
        'date_ideas',
        {
          'is_completed': true,
          'completed_date': DateTime.now().toIso8601String(),
        },
        filters: {'id': id},
      );
      await loadDateIdeas();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking date as completed: $e');
    }
  }

  Future<void> addDateIdea(DateIdeaModel idea) async {
    try {
      if (_coupleId == null) return;

      await SupabaseService.insert('date_ideas', idea.toJson(coupleId: _coupleId));
      await loadDateIdeas();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding date idea: $e');
    }
  }

  Future<void> deleteDateIdea(String id) async {
    try {
      await SupabaseService.delete('date_ideas', filters: {'id': id});
      await loadDateIdeas();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting date idea: $e');
    }
  }
}
