import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vesper/components/wellness_card.dart';
import 'package:vesper/models/appreciation_model.dart';
import 'package:vesper/services/appreciation_service.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/theme.dart';

class AppreciationArchivePage extends StatefulWidget {
  const AppreciationArchivePage({super.key});

  @override
  State<AppreciationArchivePage> createState() => _AppreciationArchivePageState();
}

class _AppreciationArchivePageState extends State<AppreciationArchivePage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserService>().user;
    final appreciationService = context.watch<AppreciationService>();

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final allEntries = appreciationService.entries;
    final sentEntries = appreciationService.sentBy(user.id);
    final receivedEntries = appreciationService.receivedBy(user.id);

    final displayedEntries = _filter == 'Sent'
        ? sentEntries
        : _filter == 'Received'
            ? receivedEntries
            : allEntries;

    final badgeCounts = appreciationService.badgesCounts();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Appreciation Archive', style: context.textStyles.titleLarge),
      ),
      body: Column(
        children: [
          _buildBadgeTrophyShelf(badgeCounts, appreciationService.totalBadgesCollected),
          _buildFilterButtons(),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: displayedEntries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: displayedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = displayedEntries[index];
                      final isSent = entry.fromUserId == user.id;
                      return _AppreciationCard(
                        appreciation: entry,
                        isSent: isSent,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTrophyShelf(Map<AppreciationBadge, int> counts, int total) {
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
              Text(
                'Trophy Shelf',
                style: context.textStyles.titleMedium?.copyWith(
                  color: VesperColors.loveOutLoudGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$total badges collected',
            style: context.textStyles.labelMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: counts.entries.where((e) => e.value > 0).map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: VesperColors.loveOutLoudGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.key.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      'x${entry.value}',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: VesperColors.loveOutLoudGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _FilterButton(
              label: 'All',
              isSelected: _filter == 'All',
              onTap: () => setState(() => _filter = 'All'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _FilterButton(
              label: 'Sent',
              isSelected: _filter == 'Sent',
              onTap: () => setState(() => _filter = 'Sent'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _FilterButton(
              label: 'Received',
              isSelected: _filter == 'Received',
              onTap: () => setState(() => _filter = 'Received'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💌', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            Text('No Appreciations Yet', style: context.textStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start sharing love and gratitude with your partner',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? VesperColors.loveOutLoudGold
              : VesperColors.accent.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textStyles.titleSmall?.copyWith(
              color: isSelected ? Colors.white : VesperColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppreciationCard extends StatefulWidget {
  final AppreciationModel appreciation;
  final bool isSent;

  const _AppreciationCard({
    required this.appreciation,
    required this.isSent,
  });

  @override
  State<_AppreciationCard> createState() => _AppreciationCardState();
}

class _AppreciationCardState extends State<_AppreciationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.appreciation;
    final displayName = widget.isSent ? (a.toUserName ?? 'Partner') : a.fromUserName;
    final emoji = widget.isSent ? '→' : '←';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: WellnessCard(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: VesperColors.loveOutLoudGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(a.selectedBadge.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(displayName, style: context.textStyles.titleMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(a.sentAt),
                        style: context.textStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: VesperColors.textSecondary,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              _Section(
                emoji: '💝',
                title: 'Appreciation',
                content: a.appreciationText,
              ),
              const SizedBox(height: AppSpacing.md),
              _Section(
                emoji: '🏆',
                title: 'Win',
                content: a.winText,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('🙏 Gratitudes', style: context.textStyles.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ...a.gratitudes.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key + 1}.', style: context.textStyles.bodyMedium),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(entry.value, style: context.textStyles.bodyMedium),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String emoji;
  final String title;
  final String content;

  const _Section({
    required this.emoji,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: context.textStyles.titleMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(content, style: context.textStyles.bodyMedium),
      ],
    );
  }
}
