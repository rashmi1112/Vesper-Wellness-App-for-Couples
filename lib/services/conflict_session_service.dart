import 'package:flutter/foundation.dart';
import 'package:vesper/models/conflict_session_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/services/user_service.dart';

class ConflictSessionService extends ChangeNotifier {
  bool _isLoading = false;
  List<ConflictSessionModel> _sessions = [];
  ConflictSessionModel? _draft;
  String? _currentUserId;
  String? _coupleId;
  UserService? _userService;

  bool get isLoading => _isLoading;
  List<ConflictSessionModel> get sessions => List.unmodifiable(_sessions);
  ConflictSessionModel? get draft => _draft;

  ConflictSessionModel? get lastResolved => _sessions.where((s) => s.isResolved).cast<ConflictSessionModel?>().firstWhere((_) => true, orElse: () => null);

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
      await loadSessions();
    } catch (e) {
      debugPrint('Failed to load conflict sessions: $e');
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

  Future<void> loadSessions() async {
    try {
      if (_currentUserId == null) return;

      // Load sessions for single users (couple_id is null) or couples
      final data = _coupleId != null
          ? await SupabaseService.select(
              'conflict_sessions',
              filters: {'couple_id': _coupleId},
              orderBy: 'started_at',
              ascending: false,
            )
          : await SupabaseService.from('conflict_sessions')
              .select()
              .eq('initiator_id', _currentUserId!)
              .order('started_at', ascending: false);

      _sessions = data.map((json) => ConflictSessionModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading conflict sessions: $e');
    }
  }

  Future<void> startNewDraft({bool breathingSkipped = false}) async {
    try {
      _draft = ConflictSessionModel(breathingSkipped: breathingSkipped);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to start conflict draft: $e');
    }
  }

  Future<void> updateDraft(ConflictSessionModel draft) async {
    try {
      _draft = draft;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update conflict draft: $e');
    }
  }

  Future<void> discardDraft() async {
    try {
      _draft = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to discard conflict draft: $e');
    }
  }

  Future<void> closeDraftAsResolved({
    required int rating,
    required String notes,
    required bool aiSummaryEnabled,
    required String aiSummaryText,
    int? followUpInDays,
  }) async {
    try {
      if (_currentUserId == null) return;

      final current = _draft ?? ConflictSessionModel();
      final resolved = current.copyWith(
        endedAt: DateTime.now(),
        resolutionRating: rating,
        resolutionNotes: notes,
        aiSummaryEnabled: aiSummaryEnabled,
        aiSummaryText: aiSummaryText,
        followUpInDays: followUpInDays,
      );

      // Pass null for couple_id if user has no partners
      final hasPartners = _userService?.currentUser?.partnerIds.isNotEmpty ?? false;
      final coupleIdToUse = hasPartners ? _coupleId : null;
      debugPrint('Closing conflict: hasPartners=$hasPartners, coupleId=$coupleIdToUse, initiatorId=$_currentUserId');
      final dataToInsert = resolved.toJson(
        coupleId: coupleIdToUse,
        initiatorId: _currentUserId!,
      );
      debugPrint('Conflict data: $dataToInsert');
      await SupabaseService.insert('conflict_sessions', dataToInsert);
      _draft = null;
      await loadSessions();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to close conflict session: $e');
    }
  }
}
