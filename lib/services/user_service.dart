import 'package:flutter/foundation.dart';
import 'package:vesper/models/user_model.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/services/notification_service.dart';

class UserService extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _currentAuthUserId;

  UserModel? get user => currentUser;
  UserModel? get currentUser => _user;
  List<UserModel> get users => _user != null ? [_user!] : [];
  bool get isLoading => _isLoading;
  bool get hasUser => currentUser != null;
  bool get isAuthenticated => currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isBiometricGateRequired => false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      final authUserId = SupabaseConfig.auth.currentUser?.id;
      if (authUserId != null) {
        _currentAuthUserId = authUserId;
        await loadUserProfile(authUserId);
        
        // If user profile doesn't exist, sign out
        if (_user == null) {
          debugPrint('No user profile found for authenticated user - signing out');
          await SupabaseConfig.auth.signOut();
          _currentAuthUserId = null;
        }
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
      // If there's an error loading the profile, sign out
      try {
        await SupabaseConfig.auth.signOut();
      } catch (signOutError) {
        debugPrint('Error signing out: $signOutError');
      }
      _currentAuthUserId = null;
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      debugPrint('Loading user profile for userId: $userId');
      final data = await SupabaseService.selectSingle(
        'users',
        filters: {'id': userId},
      );
      debugPrint('User profile data: $data');
      if (data != null) {
        _user = UserModel.fromJson(data);
        _currentAuthUserId = userId;
        notifyListeners();
        debugPrint('User profile loaded successfully: ${_user?.name}');
      } else {
        debugPrint('No user profile data found in database');
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      rethrow;
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      debugPrint('Creating user profile for: ${user.id} - ${user.name}');
      final result = await SupabaseService.insert('users', user.toJson());
      debugPrint('User profile created successfully: $result');
      _user = user;
      _currentAuthUserId = user.id;
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }


  Future<void> clearUser() async {
    _user = null;
    _currentAuthUserId = null;
    notifyListeners();
  }

  Future<void> updateCurrentUser(UserModel updated) async {
    try {
      await SupabaseService.update(
        'users',
        updated.toJson(),
        filters: {'id': updated.id},
      );
      _user = updated;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> enableBiometricsForCurrentUser(bool enabled) async {
    final u = _user;
    if (u == null) return;
    await updateCurrentUser(u.copyWith(biometricEnabled: enabled));
  }

  Future<void> unlockWithBiometrics() async {
    notifyListeners();
  }

  Future<UserModel?> findUserByEmail(String email) async {
    try {
      final data = await SupabaseService.selectSingle(
        'users',
        filters: {'email': email.trim().toLowerCase()},
      );
      return data != null ? UserModel.fromJson(data) : null;
    } catch (e) {
      debugPrint('Error finding user by email: $e');
      return null;
    }
  }

  Future<UserModel?> findUserByPhone(String phone) async {
    try {
      final data = await SupabaseService.selectSingle(
        'users',
        filters: {'phone_number': phone.replaceAll(RegExp(r'[^0-9]'), '')},
      );
      return data != null ? UserModel.fromJson(data) : null;
    } catch (e) {
      debugPrint('Error finding user by phone: $e');
      return null;
    }
  }

  Future<UserModel?> findUserById(String id) async {
    try {
      final data = await SupabaseService.selectSingle(
        'users',
        filters: {'id': id},
      );
      return data != null ? UserModel.fromJson(data) : null;
    } catch (e) {
      debugPrint('Error finding user by id: $e');
      return null;
    }
  }

  Future<void> sendLinkRequest({required String partnerUserId}) async {
    final me = _user;
    if (me == null) throw Exception('Not logged in');
    if (partnerUserId == me.id) throw Exception('You can\'t link to yourself');

    final partner = await findUserById(partnerUserId);
    if (partner == null) throw Exception('No account found');
    if (me.partnerIds.contains(partnerUserId)) throw Exception('You\'re already linked');
    if (me.outgoingLinkRequests.contains(partnerUserId)) throw Exception('Request already sent');

    final updatedMe = me.copyWith(outgoingLinkRequests: [...me.outgoingLinkRequests, partnerUserId]);
    final updatedPartner = partner.copyWith(incomingLinkRequests: [...partner.incomingLinkRequests, me.id]);
    
    await updateCurrentUser(updatedMe);
    await SupabaseService.update(
      'users',
      updatedPartner.toJson(),
      filters: {'id': updatedPartner.id},
    );
    notifyListeners();
  }

  Future<void> acceptLinkRequest({
    required String fromUserId,
    NotificationService? notificationService,
  }) async {
    final me = _user;
    if (me == null) throw Exception('Not logged in');
    if (!me.incomingLinkRequests.contains(fromUserId)) throw Exception('No pending request');
    final other = await findUserById(fromUserId);
    if (other == null) throw Exception('Linking failed, please try again');

    final updatedMe = me.copyWith(
      incomingLinkRequests: me.incomingLinkRequests.where((id) => id != fromUserId).toList(),
      partnerIds: me.partnerIds.contains(fromUserId) ? me.partnerIds : [...me.partnerIds, fromUserId],
      partnerName: me.partnerName.isEmpty ? other.name : me.partnerName,
    );

    final updatedOther = other.copyWith(
      outgoingLinkRequests: other.outgoingLinkRequests.where((id) => id != me.id).toList(),
      partnerIds: other.partnerIds.contains(me.id) ? other.partnerIds : [...other.partnerIds, me.id],
      partnerName: other.partnerName.isEmpty ? me.name : other.partnerName,
    );

    await updateCurrentUser(updatedMe);
    await SupabaseService.update(
      'users',
      updatedOther.toJson(),
      filters: {'id': updatedOther.id},
    );

    // Create pairing accepted notification for the requester if enabled
    if (other.pairingNotificationsEnabled && notificationService != null) {
      await notificationService.createPairingAcceptedNotification(
        userId: other.id,
        partnerName: me.name,
      );
    }

    notifyListeners();
  }

  Future<void> declineLinkRequest({required String fromUserId}) async {
    final me = _user;
    if (me == null) return;
    final updatedMe = me.copyWith(incomingLinkRequests: me.incomingLinkRequests.where((id) => id != fromUserId).toList());
    await updateCurrentUser(updatedMe);
  }
}
