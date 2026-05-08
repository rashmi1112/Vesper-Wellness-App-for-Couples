import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesper/pages/home_page.dart';
import 'package:vesper/pages/history_page.dart';
import 'package:vesper/pages/notifications_page.dart';
import 'package:vesper/pages/profile_page.dart';
import 'package:vesper/pages/settings_page.dart';
import 'package:vesper/pages/onboarding_page.dart';
import 'package:vesper/pages/auth/signup_flow_page.dart';
import 'package:vesper/pages/auth/auth_gate_page.dart';
import 'package:vesper/pages/shell/app_shell_page.dart';
import 'package:vesper/supabase/supabase_config.dart';
import 'package:vesper/pages/conflict/conflict_breathing_page.dart';
import 'package:vesper/pages/conflict/conflict_emotion_checkin_page.dart';
import 'package:vesper/pages/conflict/conflict_lily_page.dart';
import 'package:vesper/pages/conflict/conflict_framework_page.dart';
import 'package:vesper/pages/conflict/conflict_feedback_page.dart';
import 'package:vesper/pages/conversation_starters_page.dart';
import 'package:vesper/pages/date_ideas_page.dart';
import 'package:vesper/pages/gratitude_journal_page.dart';
import 'package:vesper/pages/milestones_page.dart';
import 'package:vesper/pages/grow_together_page.dart';
import 'package:vesper/pages/love_out_loud_page.dart';
import 'package:vesper/pages/appreciation_archive_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isAuthenticated = SupabaseConfig.auth.currentUser != null;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isSignup = state.matchedLocation == SignupFlowPage.routePath;
      final isLogin = state.matchedLocation == AppRoutes.login;

      // Not authenticated and trying to access protected routes
      if (!isAuthenticated && !isOnboarding && !isSignup && !isLogin) {
        return AppRoutes.login;
      }

      // Authenticated and trying to access auth pages
      if (isAuthenticated && (isLogin || isOnboarding)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AuthGatePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: SignupFlowPage.routePath,
        name: 'signUp',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SignupFlowPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),

      ShellRoute(
        builder: (context, state, child) => AppShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
            routes: [
              GoRoute(
                path: 'settings',
                name: 'settings',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const SettingsPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
              ),
              GoRoute(
                path: 'conversations',
                name: 'conversations',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const ConversationStartersPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
              ),
              GoRoute(
                path: 'date-ideas',
                name: 'dateIdeas',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const DateIdeasPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
              ),
              GoRoute(
                path: 'gratitude',
                name: 'gratitude',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const GratitudeJournalPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
              ),
              GoRoute(
                path: 'milestones',
                name: 'milestones',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const MilestonesPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
              ),
              GoRoute(
                path: 'grow-together',
                name: 'growTogether',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const GrowTogetherPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
              ),
              GoRoute(
                path: 'love-out-loud',
                name: 'loveOutLoud',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const LoveOutLoudPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
              ),
              GoRoute(
                path: 'appreciation-archive',
                name: 'appreciationArchive',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const AppreciationArchivePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.history,
            name: 'history',
            pageBuilder: (context, state) => const NoTransitionPage(child: HistoryPage()),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            name: 'notifications',
            pageBuilder: (context, state) => const NoTransitionPage(child: NotificationsPage()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),

      GoRoute(
        path: ConflictBreathingPage.routePath,
        name: 'conflictBreathe',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ConflictBreathingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: ConflictEmotionCheckInPage.routePath,
        name: 'conflictEmotions',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ConflictEmotionCheckInPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: ConflictLilyPage.routePath,
        name: 'conflictLily',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ConflictLilyPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: ConflictFrameworkPage.routePath,
        name: 'conflictFramework',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ConflictFrameworkPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: ConflictFeedbackPage.routePath,
        name: 'conflictFeedback',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ConflictFeedbackPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';

  static const String history = '/history';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
}
