import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vesper/components/feature_tile_card.dart';
import 'package:vesper/models/conflict_session_model.dart';
import 'package:vesper/services/conflict_session_service.dart';
import 'package:vesper/services/gratitude_service.dart';
import 'package:vesper/services/milestone_service.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  bool _isWide(double width) => width >= 900;

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();

    if (!userService.isInitialized || userService.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!userService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/onboarding');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final me = userService.user;
    final userName = (me?.name ?? '').trim().isEmpty ? 'You' : me!.name.trim();
    final userPhoto = me?.profilePhotoBase64;

    final notificationService = context.watch<NotificationService>();
    final conflictService = context.watch<ConflictSessionService>();
    final gratitudeService = context.watch<GratitudeService>();
    final milestoneService = context.watch<MilestoneService>();

    final lastConflict = conflictService.sessions.where((s) => s.isResolved).cast<ConflictSessionModel?>().firstWhere((_) => true, orElse: () => null);
    final lastAppreciation = gratitudeService.entries.isEmpty ? null : gratitudeService.entries.first;
    final nextGrowth = milestoneService.nextMilestone;

    final isActiveThisWeek = _activeThisWeek(gratitudeService, conflictService);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = _isWide(constraints.maxWidth);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                    child: _DashboardTopBar(
                      userName: userName,
                      userPhotoBase64: userPhoto,
                      unreadNotifications: notificationService.unreadCount,
                      isActiveThisWeek: isActiveThisWeek,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text('Your three pillars', style: context.textStyles.titleLarge),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _FeatureTiles(wide: wide),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text('Recent activity', style: context.textStyles.titleLarge),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                    child: Column(
                      children: [
                        _ActivityCard(
                          icon: Icons.handshake_rounded,
                          accent: VesperColors.fightBetterTeal,
                          title: 'Last conflict session',
                          subtitle: lastConflict == null
                              ? 'No sessions yet'
                              : 'Rating: ${lastConflict.resolutionRating ?? '—'}/5 • ${DateFormat('MMM d').format(lastConflict.startedAt)}',
                          body: lastConflict == null
                              ? 'When you use Fight Better, you\'ll see a gentle recap here.'
                              : (lastConflict.aiSummaryText.trim().isNotEmpty ? lastConflict.aiSummaryText : _fallbackConflictLine(lastConflict)),
                          ctaLabel: lastConflict == null ? 'Start Fight Better' : 'View in History',
                          onTap: () => lastConflict == null ? context.push('/conflict/breathe') : context.go('/history'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ActivityCard(
                          icon: Icons.auto_awesome_rounded,
                          accent: VesperColors.loveOutLoudGold,
                          title: 'Last appreciation sent',
                          subtitle: lastAppreciation == null ? 'None yet' : DateFormat('MMM d').format(lastAppreciation.date),
                          body: lastAppreciation?.content ?? 'Your next warm note can be tiny. It still counts.',
                          ctaLabel: 'Open Journal',
                          onTap: () => context.push('/gratitude'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ActivityCard(
                          icon: Icons.event_rounded,
                          accent: VesperColors.growTogetherSage,
                          title: 'Upcoming growth date',
                          subtitle: nextGrowth == null ? 'Not scheduled' : '${nextGrowth.daysUntil} days',
                          body: nextGrowth == null
                              ? 'Add a milestone for your next Growth Date, and we\'ll show a countdown here.'
                              : '${nextGrowth.title} • ${DateFormat('MMM d').format(nextGrowth.date)}',
                          ctaLabel: 'Open Growth',
                          onTap: () => context.push('/milestones'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _activeThisWeek(GratitudeService gratitude, ConflictSessionService conflict) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final hasGratitude = gratitude.entries.any((e) => e.date.isAfter(weekAgo));
    final hasConflict = conflict.sessions.any((s) => s.startedAt.isAfter(weekAgo));
    return hasGratitude || hasConflict;
  }

  String _fallbackConflictLine(ConflictSessionModel s) {
    final emotions = s.emotions.isEmpty ? '—' : s.emotions.take(3).join(', ');
    if (s.resolutionNotes.trim().isNotEmpty) return s.resolutionNotes.trim();
    return 'Emotions: $emotions';
  }
}

class _DashboardTopBar extends StatelessWidget {
  final String userName;
  final String? userPhotoBase64;
  final int unreadNotifications;
  final bool isActiveThisWeek;

  const _DashboardTopBar({
    required this.userName,
    required this.userPhotoBase64,
    required this.unreadNotifications,
    required this.isActiveThisWeek,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = (isDark ? VesperColors.darkSurfaceVariant : VesperColors.surfaceVariant).withValues(alpha: 0.9);

    return Row(
      children: [
        _UserPill(name: userName, photoBase64: userPhotoBase64),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: VesperColors.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(isActiveThisWeek ? Icons.bolt_rounded : Icons.bolt_outlined, color: VesperColors.primary, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(isActiveThisWeek ? 'Active this week' : 'Take a tiny step', style: context.textStyles.labelMedium),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.go('/notifications'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VesperColors.accent.withValues(alpha: 0.35)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(child: Icon(Icons.notifications_rounded, color: VesperColors.primary)),
                if (unreadNotifications > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: VesperColors.primary, shape: BoxShape.circle)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UserPill extends StatelessWidget {
  final String name;
  final String? photoBase64;

  const _UserPill({required this.name, required this.photoBase64});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bytes = (photoBase64 == null || photoBase64!.isEmpty) ? null : base64Decode(photoBase64!);

    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: (isDark ? VesperColors.darkSurfaceVariant : VesperColors.surfaceVariant).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: VesperColors.accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: VesperColors.accent.withValues(alpha: 0.55),
              foregroundImage: bytes == null ? null : MemoryImage(bytes),
              child: bytes == null
                  ? Text(
                      name.characters.first.toUpperCase(),
                      style: context.textStyles.labelMedium?.copyWith(color: VesperColors.primary, fontWeight: FontWeight.w800),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(name, style: context.textStyles.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _FeatureTiles extends StatelessWidget {
  final bool wide;

  const _FeatureTiles({required this.wide});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      FeatureTileCard(
        title: 'Fight Better',
        description: 'Conflict Resolution System',
        icon: Icons.local_florist_rounded,
        accentColor: VesperColors.fightBetterTeal,
        onTap: () => context.push('/conflict/breathe'),
      ),
      FeatureTileCard(
        title: 'Grow Together',
        description: 'Monthly Growth System',
        icon: Icons.spa_rounded,
        accentColor: VesperColors.growTogetherSage,
        onTap: () => context.push('/grow-together'),
      ),
      FeatureTileCard(
        title: 'Love Out Loud',
        description: 'Appreciation Tracker',
        icon: Icons.auto_awesome_rounded,
        accentColor: VesperColors.loveOutLoudGold,
        onTap: () => context.push('/love-out-loud'),
      ),
    ];

    if (!wide) {
      return Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.6,
      children: tiles,
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String body;
  final String ctaLabel;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? VesperColors.darkSurface : VesperColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: accent.withValues(alpha: isDark ? 0.22 : 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: accent.withValues(alpha: isDark ? 0.18 : 0.12), borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textStyles.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle, style: context.textStyles.labelSmall),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: accent),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(body, style: context.textStyles.bodyMedium?.copyWith(height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(ctaLabel, style: context.textStyles.labelLarge?.copyWith(color: accent)),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.arrow_forward_rounded, color: accent, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
