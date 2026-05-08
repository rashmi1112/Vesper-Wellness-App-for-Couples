import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/services/gratitude_service.dart';
import 'package:vesper/services/date_idea_service.dart';
import 'package:vesper/services/milestone_service.dart';
import 'package:vesper/services/conversation_service.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/services/conflict_session_service.dart';
import 'package:vesper/services/appreciation_service.dart';
import 'package:vesper/services/growth_challenge_service.dart';
import 'package:vesper/services/check_in_service.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/auth/supabase_auth_manager.dart';
import 'package:vesper/theme.dart';
import 'package:vesper/nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _handleDeepLinks();
  }

  void _setupAuthListener() {
    SupabaseConfig.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session?.user != null) {
        // User logged in - reload all services
        if (mounted) {
          final userService = context.read<UserService>();
          await userService.loadUserProfile(session!.user.id);
          
          // Reload all other services with userService reference
          context.read<NotificationService>().initialize();
          context.read<ConflictSessionService>().initialize(userService: userService);
          context.read<GratitudeService>().initialize(userService: userService);
          context.read<DateIdeaService>().initialize(userService: userService);
          context.read<MilestoneService>().initialize(userService: userService);
          context.read<AppreciationService>().initialize(userService: userService);
          context.read<GrowthChallengeService>().initialize(userService: userService);
          context.read<CheckInService>().initialize(userService: userService);
        }
      } else {
        // User logged out - clear all services
        if (mounted) {
          context.read<UserService>().clearUser();
        }
      }
    });
  }

  void _handleDeepLinks() {
    // Listen for deep link authentication events (password reset, magic links, etc.)
    SupabaseConfig.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      debugPrint('Auth event: $event');
      
      if (event == AuthChangeEvent.passwordRecovery) {
        // Show password reset dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showPasswordResetDialog();
          }
        });
      }
    });
    
    // For web, manually check URL hash on startup
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final uri = Uri.base;
        debugPrint('Current URL: $uri');
        debugPrint('Fragment: ${uri.fragment}');
        
        // Check if URL contains password recovery token
        if (uri.fragment.contains('type=recovery') || 
            uri.fragment.contains('type=password_recovery')) {
          debugPrint('Password recovery detected in URL');
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _showPasswordResetDialog();
          }
        }
      });
    }
  }

  void _showPasswordResetDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              newPasswordController.dispose();
              confirmPasswordController.dispose();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (newPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a password')),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }

              try {
                await SupabaseConfig.auth.updateUser(
                  UserAttributes(password: newPassword),
                );
                
                Navigator.of(context).pop();
                newPasswordController.dispose();
                confirmPasswordController.dispose();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update password: $e')),
                );
              }
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => SupabaseAuthManager()),
        ChangeNotifierProvider(create: (_) => UserService()..initialize()),
        ChangeNotifierProxyProvider<UserService, NotificationService>(
          create: (_) => NotificationService(),
          update: (_, userService, notificationService) => notificationService!..initialize(),
        ),
        ChangeNotifierProxyProvider<UserService, ConflictSessionService>(
          create: (_) => ConflictSessionService(),
          update: (_, userService, conflictService) => conflictService!..initialize(userService: userService),
        ),
        ChangeNotifierProxyProvider<UserService, GratitudeService>(
          create: (_) => GratitudeService(),
          update: (_, userService, gratitudeService) => gratitudeService!..initialize(userService: userService),
        ),
        ChangeNotifierProxyProvider<UserService, DateIdeaService>(
          create: (_) => DateIdeaService(),
          update: (_, userService, dateIdeaService) => dateIdeaService!..initialize(userService: userService),
        ),
        ChangeNotifierProxyProvider<UserService, MilestoneService>(
          create: (_) => MilestoneService(),
          update: (_, userService, milestoneService) => milestoneService!..initialize(userService: userService),
        ),
        ChangeNotifierProxyProvider<UserService, AppreciationService>(
          create: (_) => AppreciationService(),
          update: (_, userService, appreciationService) => appreciationService!..initialize(userService: userService),
        ),
        ChangeNotifierProxyProvider<UserService, GrowthChallengeService>(
          create: (_) => GrowthChallengeService(),
          update: (_, userService, challengeService) => challengeService!..initialize(userService: userService),
        ),
        ChangeNotifierProxyProvider<UserService, CheckInService>(
          create: (_) => CheckInService(),
          update: (_, userService, checkInService) => checkInService!..initialize(userService: userService),
        ),
        Provider(create: (_) => ConversationService()),
      ],
      child: MaterialApp.router(
        title: 'Vesper',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
