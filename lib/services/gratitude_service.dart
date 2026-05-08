import 'package:flutter/foundation.dart';
import 'package:vesper/models/gratitude_entry_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/services/user_service.dart';

class GratitudeService extends ChangeNotifier {
  List<GratitudeEntryModel> _entries = [];
  bool _isLoading = false;
  String? _currentUserId;
  String? _coupleId;
  UserService? _userService;

  List<GratitudeEntryModel> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  List<String> get categories => [
    'Quality Time',
    'Acts of Service',
    'Words of Affirmation',
    'Physical Touch',
    'Gifts',
    'Support',
    'Adventure',
  ];

  int get totalEntries => _entries.length;

  List<GratitudeEntryModel> get recentEntries => _entries.take(5).toList();

  Map<String, int> get entriesByCategory {
    final map = <String, int>{};
    for (var entry in _entries) {
      map[entry.category] = (map[entry.category] ?? 0) + 1;
    }
    return map;
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
      await loadEntries();
    } catch (e) {
      debugPrint('Error loading gratitude entries: $e');
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

  Future<void> loadEntries() async {
    try {
      if (_currentUserId == null || _coupleId == null) return;

      final data = await SupabaseService.select(
        'gratitude_entries',
        filters: {'couple_id': _coupleId, 'user_id': _currentUserId},
        orderBy: 'date',
        ascending: false,
      );

      _entries = data.map((json) => GratitudeEntryModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading gratitude entries: $e');
    }
  }

  Future<void> addEntry({
    required String content,
    required String category,
  }) async {
    try {
      if (_currentUserId == null || _coupleId == null) return;

      final entry = GratitudeEntryModel(
        content: content,
        category: category,
        date: DateTime.now(),
      );
      
      await SupabaseService.insert('gratitude_entries', entry.toJson(coupleId: _coupleId, userId: _currentUserId));
      await loadEntries();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding gratitude entry: $e');
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await SupabaseService.delete('gratitude_entries', filters: {'id': id});
      await loadEntries();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting gratitude entry: $e');
    }
  }
}
