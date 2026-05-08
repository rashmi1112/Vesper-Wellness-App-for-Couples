import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vesper/auth/auth_manager.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/models/user_model.dart';

/// Supabase implementation of AuthManager with email/password authentication
class SupabaseAuthManager extends AuthManager with EmailSignInManager {
  final _auth = SupabaseConfig.auth;
  final _client = SupabaseConfig.client;

  @override
  String? get currentUserId => _auth.currentUser?.id;

  @override
  Stream<String?> get authStateChanges =>
      _auth.onAuthStateChange.map((event) => event.session?.user.id);

  @override
  Future<String?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user?.id;
    } on AuthException catch (e) {
      debugPrint('Sign in error: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Sign in error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign in. Please try again.')),
        );
      }
      return null;
    }
  }

  @override
  Future<String?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Disable email confirmation for development
      );

      if (response.user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create account. Please try again.'),
            ),
          );
        }
        return null;
      }

      return response.user!.id;
    } on AuthException catch (e) {
      debugPrint('Sign up error: ${e.message}');
      if (context.mounted) {
        String message = e.message;
        
        // Handle specific error messages
        if (message.contains('rate limit')) {
          message = 'Too many signup attempts. Please wait a few minutes and try again.';
        } else if (message.contains('email confirmation')) {
          message = 'Please verify your email before signing in.';
        } else if (message.contains('already registered')) {
          message = 'This email is already registered. Please sign in instead.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Sign up error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account. Please try again.'),
          ),
        );
      }
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      // Delete user from Supabase (this will cascade delete related data)
      await SupabaseService.delete('users', filters: {'id': userId});
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
      }
    } catch (e) {
      debugPrint('Delete user error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account')),
        );
      }
    }
  }

  @override
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.updateUser(UserAttributes(email: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated successfully')),
        );
      }
    } on AuthException catch (e) {
      debugPrint('Update email error: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      debugPrint('Update email error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update email')),
        );
      }
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      // Get the current URL to use as redirect
      final redirectUrl = kIsWeb 
          ? Uri.base.origin
          : 'togetherly://reset-password';
      
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent. Please check your inbox.'),
          ),
        );
      }
    } on AuthException catch (e) {
      debugPrint('Reset password error: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset email')),
        );
      }
    }
  }

  /// Create or update user profile in database after authentication
  Future<void> createUserProfile(UserModel user) async {
    try {
      final existingUser = await SupabaseService.selectSingle(
        'users',
        filters: {'id': user.id},
      );

      if (existingUser == null) {
        // Create new user profile
        await SupabaseService.insert('users', user.toJson());
      } else {
        // Update existing user profile
        await SupabaseService.update(
          'users',
          user.toJson(),
          filters: {'id': user.id},
        );
      }
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile from database
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await SupabaseService.selectSingle(
        'users',
        filters: {'id': userId},
      );

      if (data == null) return null;
      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }
}
