import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/theme.dart';

class AppShellPage extends StatelessWidget {
  final Widget child;

  const AppShellPage({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/notifications')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  String _indexToLocation(int index) {
    switch (index) {
      case 1:
        return '/history';
      case 2:
        return '/notifications';
      case 3:
        return '/profile';
      default:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);
    final unread = context.watch<NotificationService>().unreadCount;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? VesperColors.darkSurface : VesperColors.surface,
            border: Border(top: BorderSide(color: (isDark ? VesperColors.darkSurfaceVariant : VesperColors.accent).withValues(alpha: 0.35), width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              final target = _indexToLocation(index);
              if (target == location) return;
              context.go(target);
            },
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            selectedItemColor: VesperColors.primary,
            unselectedItemColor: isDark ? VesperColors.darkTextSecondary : VesperColors.textSecondary,
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home_rounded, color: VesperColors.primary), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.history_rounded, color: isDark ? VesperColors.darkTextSecondary : VesperColors.textSecondary), label: 'History'),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_rounded, color: isDark ? VesperColors.darkTextSecondary : VesperColors.textSecondary),
                    if (unread > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: VesperColors.primary, borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: context.textStyles.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded, color: isDark ? VesperColors.darkTextSecondary : VesperColors.textSecondary), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
