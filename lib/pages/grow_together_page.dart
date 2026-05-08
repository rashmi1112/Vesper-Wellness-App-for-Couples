import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vesper/components/wellness_card.dart';
import 'package:vesper/models/growth_challenge_model.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/services/growth_challenge_service.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/theme.dart';

class GrowTogetherPage extends StatefulWidget {
  const GrowTogetherPage({super.key});

  @override
  State<GrowTogetherPage> createState() => _GrowTogetherPageState();
}

class _GrowTogetherPageState extends State<GrowTogetherPage> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserService>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Grow Together', style: context.textStyles.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCountdownSection(user),
            const SizedBox(height: AppSpacing.xl),
            _buildGrowthChallengesSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildUpcomingGrowthDate(user),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownSection(user) {
    final anniversaryDate = user.anniversaryDate;
    final daysTogether = DateTime.now().difference(anniversaryDate).inDays;
    final yearsTogether = (daysTogether / 365).floor();
    final monthsTogether = ((daysTogether % 365) / 30).floor();
    
    // Calculate next anniversary
    final now = DateTime.now();
    var nextAnniversary = DateTime(now.year, anniversaryDate.month, anniversaryDate.day);
    if (nextAnniversary.isBefore(now)) {
      nextAnniversary = DateTime(now.year + 1, anniversaryDate.month, anniversaryDate.day);
    }
    final daysUntilAnniversary = nextAnniversary.difference(now).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Journey', style: context.textStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          color: VesperColors.growTogetherSage.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const Text('💕', style: TextStyle(fontSize: 64)),
                const SizedBox(height: AppSpacing.md),
                if (user.partnerName.trim().isNotEmpty)
                  Text(
                    'You & ${user.partnerName}',
                    style: context.textStyles.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Together since ${DateFormat('MMMM d, yyyy').format(anniversaryDate)}',
                  style: context.textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _CountdownStat(
                        icon: Icons.calendar_today,
                        value: '$daysTogether',
                        label: 'Days Together',
                      ),
                    ),
                    Container(width: 1, height: 60, color: VesperColors.accent),
                    Expanded(
                      child: _CountdownStat(
                        icon: Icons.favorite,
                        value: yearsTogether > 0 
                            ? '$yearsTogether ${yearsTogether == 1 ? 'Year' : 'Years'}' 
                            : '$monthsTogether ${monthsTogether == 1 ? 'Month' : 'Months'}',
                        label: 'Time Together',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: VesperColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.celebration, color: VesperColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Next anniversary in $daysUntilAnniversary days',
                        style: context.textStyles.titleMedium?.copyWith(color: VesperColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthChallengesSection() {
    final challengeService = context.watch<GrowthChallengeService>();
    final activeChallenges = challengeService.activeChallenges;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Growth Challenges', style: context.textStyles.titleLarge),
            const Spacer(),
            TextButton.icon(
              onPressed: _showCreateChallengeSheet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Set monthly challenges for each other to grow individually and as a couple',
          style: context.textStyles.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        activeChallenges.isEmpty
            ? _buildEmptyGrowthChallenges()
            : Column(
                children: activeChallenges
                    .map((challenge) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _ChallengePreviewCard(challenge: challenge),
                        ))
                    .toList(),
              ),
        if (activeChallenges.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: () => context.go('/history'),
              child: const Text('View All Challenges in History →'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyGrowthChallenges() {
    return WellnessCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text('No Active Challenges', style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first growth challenge on your monthly Growth Date',
              style: context.textStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: _showCreateChallengeSheet,
              icon: const Icon(Icons.add),
              label: const Text('Create Challenge'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingGrowthDate(user) {
    final now = DateTime.now();
    final growthDay = user.growthDateDayOfMonth;
    
    DateTime nextGrowthDate;
    if (now.day < growthDay) {
      nextGrowthDate = DateTime(now.year, now.month, growthDay);
    } else {
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      nextGrowthDate = DateTime(nextYear, nextMonth, growthDay);
    }
    
    final daysUntil = nextGrowthDate.difference(now).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next Growth Date', style: context.textStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        WellnessCard(
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: VesperColors.growTogetherSage.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$daysUntil',
                    style: context.textStyles.headlineMedium?.copyWith(
                      color: VesperColors.growTogetherSage,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Day $growthDay of every month', style: context.textStyles.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateFormat('EEEE, MMMM d').format(nextGrowthDate),
                      style: context.textStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Set new challenges, check progress, celebrate wins',
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Change your Growth Date schedule in Settings > Couple Settings',
          style: context.textStyles.labelSmall,
        ),
      ],
    );
  }

  void _showCreateChallengeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateChallengeSheet(),
    );
  }
}

class _CountdownStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _CountdownStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: VesperColors.primary, size: 24),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: context.textStyles.headlineSmall?.copyWith(color: VesperColors.primary)),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: context.textStyles.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _CreateChallengeSheet extends StatefulWidget {
  const _CreateChallengeSheet();

  @override
  State<_CreateChallengeSheet> createState() => _CreateChallengeSheetState();
}

class _CreateChallengeSheetState extends State<_CreateChallengeSheet> {
  final _titleController = TextEditingController();
  final _whyController = TextEditingController();
  final _howController = TextEditingController();
  String _complexity = 'Medium';
  String _assignedTo = 'Myself';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _whyController.dispose();
    _howController.dispose();
    super.dispose();
  }

  Future<void> _createChallenge() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a challenge title')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = context.read<UserService>().user;
      if (user == null) throw Exception('Please log in');

      final isAssignedToSelf = _assignedTo == 'Myself';
      
      ChallengeComplexity complexity;
      switch (_complexity) {
        case 'Easy':
          complexity = ChallengeComplexity.easy;
          break;
        case 'Hard':
          complexity = ChallengeComplexity.hard;
          break;
        default:
          complexity = ChallengeComplexity.medium;
      }

      // Get partner's user ID
      String assignedToUserId;
      String assignedToUserName;
      if (isAssignedToSelf) {
        assignedToUserId = user.id;
        assignedToUserName = user.name;
      } else {
        // Get actual partner ID from partnerIds list
        if (user.partnerIds.isNotEmpty) {
          assignedToUserId = user.partnerIds.first;
          assignedToUserName = user.partnerName.trim();
        } else {
          // No partner linked yet - assign to self as fallback
          assignedToUserId = user.id;
          assignedToUserName = user.name;
        }
      }

      final challenge = GrowthChallengeModel(
        title: _titleController.text.trim(),
        why: _whyController.text.trim(),
        howToHelp: _howController.text.trim(),
        complexity: complexity,
        setByUserId: user.id,
        setByUserName: user.name,
        assignedToUserId: assignedToUserId,
        assignedToUserName: assignedToUserName,
        status: ChallengeStatus.notStarted,
      );

      await context.read<GrowthChallengeService>().addChallenge(
        challenge,
        userService: context.read<UserService>(),
        notificationService: context.read<NotificationService>(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Growth challenge created! 🌱'),
            backgroundColor: VesperColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create challenge: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserService>().user;
    
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: VesperColors.accent, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('🌱', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text('Create Growth Challenge', style: context.textStyles.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Set a meaningful challenge to help your partner grow',
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Challenge Title',
                hintText: 'e.g., Practice meditation daily',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _whyController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Why this matters',
                hintText: 'Share why you think this would help them grow',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _howController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'How you can help',
                hintText: 'What support will you provide?',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Assign to', style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ChoiceChip(
                    label: 'Myself',
                    isSelected: _assignedTo == 'Myself',
                    onTap: () => setState(() => _assignedTo = 'Myself'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ChoiceChip(
                    label: user?.partnerName ?? 'Partner',
                    isSelected: _assignedTo == 'Partner',
                    onTap: () => setState(() => _assignedTo = 'Partner'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Complexity', style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ChoiceChip(
                    label: 'Easy',
                    isSelected: _complexity == 'Easy',
                    onTap: () => setState(() => _complexity = 'Easy'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ChoiceChip(
                    label: 'Medium',
                    isSelected: _complexity == 'Medium',
                    onTap: () => setState(() => _complexity = 'Medium'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ChoiceChip(
                    label: 'Hard',
                    isSelected: _complexity == 'Hard',
                    onTap: () => setState(() => _complexity = 'Hard'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _createChallenge,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Challenge'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? VesperColors.primary 
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

class _ChallengePreviewCard extends StatelessWidget {
  final GrowthChallengeModel challenge;

  const _ChallengePreviewCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return WellnessCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                  child: Text(
                    challenge.complexityLabel,
                    style: context.textStyles.labelSmall?.copyWith(
                      color: _getComplexityColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${challenge.daysRemaining} days left',
                  style: context.textStyles.labelSmall?.copyWith(color: VesperColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(challenge.title, style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'For ${challenge.assignedToUserName}',
              style: context.textStyles.bodySmall,
            ),
            if (challenge.why.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                challenge.why,
                style: context.textStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
}
