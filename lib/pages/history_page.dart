import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vesper/models/appreciation_model.dart';
import 'package:vesper/models/growth_challenge_model.dart';
import 'package:vesper/services/conflict_session_service.dart';
import 'package:vesper/services/appreciation_service.dart';
import 'package:vesper/services/growth_challenge_service.dart';
import 'package:vesper/theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Text('History', style: context.textStyles.headlineSmall),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (isDark ? VesperColors.darkSurfaceVariant : VesperColors.surfaceVariant).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: (isDark ? VesperColors.darkSurfaceVariant : VesperColors.accent).withValues(alpha: 0.35)),
                  ),
                  child: Text('Shared records', style: context.textStyles.labelMedium),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? VesperColors.darkSurface : VesperColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: (isDark ? VesperColors.darkSurfaceVariant : VesperColors.accent).withValues(alpha: 0.35)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: VesperColors.primary,
                unselectedLabelColor: isDark ? VesperColors.darkTextSecondary : VesperColors.textSecondary,
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Conflict'),
                  Tab(text: 'Growth'),
                  Tab(text: 'Appreciation'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ConflictTab(),
                _GrowthTab(),
                _AppreciationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tab 1: Conflict Sessions
class _ConflictTab extends StatelessWidget {
  const _ConflictTab();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ConflictSessionService>();
    final sessions = service.sessions;

    if (service.isLoading) return const Center(child: CircularProgressIndicator());
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🤝', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text('No conflict sessions yet', style: context.textStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text('When you use Fight Better, your sessions will show up here.', style: context.textStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final s = sessions[index];
        final date = DateFormat('MMM d, h:mm a').format(s.startedAt);
        final durMin = s.duration.inMinutes;
        final rating = s.resolutionRating;
        final summary = s.resolutionNotes.trim().isEmpty
            ? (s.emotions.isEmpty ? 'Conflict session' : s.emotions.take(3).join(', '))
            : s.resolutionNotes.trim();

        return ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          backgroundColor: Theme.of(context).cardColor,
          collapsedBackgroundColor: Theme.of(context).cardColor,
          title: Row(
            children: [
              Text('Session', style: context.textStyles.titleMedium),
              const SizedBox(width: AppSpacing.sm),
              Text(date, style: context.textStyles.labelMedium),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('$durMin min', style: context.textStyles.labelSmall),
                    if (rating != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text('•', style: context.textStyles.labelSmall),
                      const SizedBox(width: AppSpacing.sm),
                      _StarRating(rating: rating),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(summary, style: context.textStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          children: [
            _DetailRow(label: 'Emotions', value: s.emotions.isEmpty ? '—' : s.emotions.join(', ')),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(label: 'Trigger', value: s.triggerText.trim().isEmpty ? '—' : s.triggerText.trim()),
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(label: 'Needs', value: s.needs.isEmpty ? '—' : s.needs.join(', ')),
            if (s.resolutionNotes.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(label: 'Notes', value: s.resolutionNotes.trim()),
            ],
            if (s.aiSummaryEnabled && s.aiSummaryText.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(label: 'Summary', value: s.aiSummaryText.trim()),
            ],
          ],
        );
      },
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: VesperColors.loveOutLoudGold,
        );
      }),
    );
  }
}

// Tab 2: Growth Journey
class _GrowthTab extends StatelessWidget {
  const _GrowthTab();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<GrowthChallengeService>();
    final challenges = service.challenges;

    if (service.isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        if (challenges.isNotEmpty) ...[
          _GrowthStats(
            totalCompleted: service.totalCompleted,
            completionRate: service.completionRate,
            currentStreak: service.currentStreak,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Expanded(
          child: challenges.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSpacing.md),
                      Text('No growth challenges yet', style: context.textStyles.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text('When you create challenges in Grow Together, they\'ll show up here.', style: context.textStyles.bodyMedium),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                  itemCount: challenges.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _ChallengeCard(challenge: challenges[index]),
                ),
        ),
      ],
    );
  }
}

class _GrowthStats extends StatelessWidget {
  final int totalCompleted;
  final double completionRate;
  final int currentStreak;

  const _GrowthStats({
    required this.totalCompleted,
    required this.completionRate,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: VesperColors.growTogetherSage.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(icon: Icons.check_circle_outline, label: 'Completed', value: '$totalCompleted')),
          Container(width: 1, height: 40, color: VesperColors.accent),
          Expanded(child: _StatItem(icon: Icons.percent, label: 'Rate', value: '${completionRate.toStringAsFixed(0)}%')),
          Container(width: 1, height: 40, color: VesperColors.accent),
          Expanded(child: _StatItem(icon: Icons.local_fire_department, label: 'Streak', value: '$currentStreak')),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: VesperColors.growTogetherSage, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: context.textStyles.titleMedium?.copyWith(color: VesperColors.growTogetherSage)),
        Text(label, style: context.textStyles.labelSmall),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final GrowthChallengeModel challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: _getComplexityColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(challenge.complexityLabel, style: context.textStyles.labelSmall?.copyWith(color: _getComplexityColor(), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(challenge.statusLabel, style: context.textStyles.labelSmall?.copyWith(color: _getStatusColor(), fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                if (challenge.isCompleted) const Icon(Icons.check_circle, color: VesperColors.success, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(challenge.title, style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text('Set by ${challenge.setByUserName}', style: context.textStyles.labelSmall),
                const SizedBox(width: AppSpacing.sm),
                Text('→', style: context.textStyles.labelSmall),
                const SizedBox(width: AppSpacing.sm),
                Text(challenge.assignedToUserName, style: context.textStyles.labelSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: VesperColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${DateFormat('MMM d').format(challenge.startDate)} - ${DateFormat('MMM d, yyyy').format(challenge.targetDate)}',
                  style: context.textStyles.labelSmall,
                ),
                const Spacer(),
                if (!challenge.isCompleted && challenge.daysRemaining > 0)
                  Text('${challenge.daysRemaining} days left', style: context.textStyles.labelSmall?.copyWith(color: VesperColors.primary)),
              ],
            ),
            if (challenge.progressPercent > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: challenge.progressPercent / 100,
                backgroundColor: VesperColors.accent.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(VesperColors.growTogetherSage),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getComplexityColor() {
    switch (challenge.complexity) {
      case ChallengeComplexity.easy:
        return VesperColors.success;
      case ChallengeComplexity.medium:
        return VesperColors.warning;
      case ChallengeComplexity.hard:
        return VesperColors.error;
    }
  }

  Color _getStatusColor() {
    switch (challenge.status) {
      case ChallengeStatus.notStarted:
        return VesperColors.textSecondary;
      case ChallengeStatus.inProgress:
        return VesperColors.primary;
      case ChallengeStatus.completed:
        return VesperColors.success;
      case ChallengeStatus.abandoned:
        return VesperColors.error;
    }
  }
}

// Tab 3: Appreciation Wall
class _AppreciationTab extends StatelessWidget {
  const _AppreciationTab();

  @override
  Widget build(BuildContext context) {
    final appreciations = context.watch<AppreciationService>().entries;
    final badgeCounts = context.watch<AppreciationService>().badgesCounts();
    final totalBadges = context.watch<AppreciationService>().totalBadgesCollected;

    return Column(
      children: [
        if (appreciations.isNotEmpty) ...[
          _TrophyShelf(badgeCounts: badgeCounts, totalBadges: totalBadges),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Text('${appreciations.length} appreciations', style: context.textStyles.bodyMedium),
                const Spacer(),
                TextButton(onPressed: () => context.push('/appreciation-archive'), child: const Text('Full Archive →')),
              ],
            ),
          ),
        ],
        Expanded(
          child: appreciations.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💕', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSpacing.md),
                      Text('No appreciations yet', style: context.textStyles.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text('When you use Love Out Loud, your appreciations will show up here.', style: context.textStyles.bodyMedium),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: appreciations.length,
                  itemBuilder: (context, index) => _AppreciationGridCard(appreciation: appreciations[index]),
                ),
        ),
      ],
    );
  }
}

class _TrophyShelf extends StatelessWidget {
  final Map<AppreciationBadge, int> badgeCounts;
  final int totalBadges;

  const _TrophyShelf({required this.badgeCounts, required this.totalBadges});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: VesperColors.loveOutLoudGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Text('Trophy Shelf', style: context.textStyles.titleMedium?.copyWith(color: VesperColors.loveOutLoudGold)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('$totalBadges badges collected', style: context.textStyles.labelMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: badgeCounts.entries.where((e) => e.value > 0).map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: VesperColors.loveOutLoudGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.key.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text('x${entry.value}', style: context.textStyles.labelSmall?.copyWith(color: VesperColors.loveOutLoudGold, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AppreciationGridCard extends StatelessWidget {
  final AppreciationModel appreciation;

  const _AppreciationGridCard({required this.appreciation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullAppreciation(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(appreciation.selectedBadge.emoji, style: const TextStyle(fontSize: 32)),
                  const Spacer(),
                  Text(DateFormat('MMM d').format(appreciation.sentAt), style: context.textStyles.labelSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(appreciation.fromUserName, style: context.textStyles.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: Text(appreciation.appreciationText, style: context.textStyles.bodySmall, maxLines: 4, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullAppreciation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(appreciation.selectedBadge.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appreciation.fromUserName, style: context.textStyles.titleLarge),
                          Text(DateFormat('EEEE, MMMM d, yyyy').format(appreciation.sentAt), style: context.textStyles.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text('💝 Appreciation', style: context.textStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(appreciation.appreciationText, style: context.textStyles.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                Text('🏆 Win', style: context.textStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(appreciation.winText, style: context.textStyles.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                Text('🙏 Gratitudes', style: context.textStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                ...appreciation.gratitudes.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text('${entry.key + 1}. ${entry.value}', style: context.textStyles.bodyMedium),
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 92, child: Text(label, style: context.textStyles.labelSmall)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(value, style: context.textStyles.bodyMedium)),
      ],
    );
  }
}
