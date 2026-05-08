import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/models/appreciation_model.dart';
import 'package:vesper/services/appreciation_service.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/theme.dart';

class LoveOutLoudPage extends StatefulWidget {
  const LoveOutLoudPage({super.key});

  @override
  State<LoveOutLoudPage> createState() => _LoveOutLoudPageState();
}

class _LoveOutLoudPageState extends State<LoveOutLoudPage> {
  final _appreciationController = TextEditingController();
  final _winController = TextEditingController();
  final _gratitude1Controller = TextEditingController();
  final _gratitude2Controller = TextEditingController();
  final _gratitude3Controller = TextEditingController();

  @override
  void dispose() {
    _appreciationController.dispose();
    _winController.dispose();
    _gratitude1Controller.dispose();
    _gratitude2Controller.dispose();
    _gratitude3Controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (_appreciationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share what you appreciate about your partner')),
      );
      return;
    }
    if (_winController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share one win to celebrate')),
      );
      return;
    }
    if (_gratitude1Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one gratitude')),
      );
      return;
    }

    final gratitudes = [
      _gratitude1Controller.text.trim(),
      if (_gratitude2Controller.text.trim().isNotEmpty) _gratitude2Controller.text.trim(),
      if (_gratitude3Controller.text.trim().isNotEmpty) _gratitude3Controller.text.trim(),
    ];

    _showBadgeSelection(
      appreciationText: _appreciationController.text.trim(),
      winText: _winController.text.trim(),
      gratitudes: gratitudes,
    );
  }

  void _showBadgeSelection({
    required String appreciationText,
    required String winText,
    required List<String> gratitudes,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BadgeSelectionSheet(
        appreciationText: appreciationText,
        winText: winText,
        gratitudes: gratitudes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserService>().user;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              VesperColors.loveOutLoudGold.withValues(alpha: 0.15),
              VesperColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Text('Love Out Loud', style: context.textStyles.titleLarge),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: Text('✨', style: TextStyle(fontSize: 64))),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Weekly Appreciation',
                        style: context.textStyles.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Take a moment to reflect and share love',
                        style: context.textStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _QuestionCard(
                        number: 1,
                        emoji: '💝',
                        title: 'Appreciate Your Partner',
                        label: 'One thing I appreciate about ${user?.partnerName ?? 'you'} this week',
                        hintText: 'e.g., You made me tea without asking and it made my whole day.',
                        controller: _appreciationController,
                        maxLines: 4,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _QuestionCard(
                        number: 2,
                        emoji: '🏆',
                        title: 'Boast Your Win',
                        label: 'One win I want to celebrate about myself',
                        hintText: 'e.g., I finally finished that course I had been putting off for three months.',
                        controller: _winController,
                        maxLines: 4,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _QuestionCard(
                        number: 3,
                        emoji: '🙏',
                        title: 'Three Gratitudes',
                        label: 'Three things I am grateful for this week',
                        controller: _gratitude1Controller,
                        controller2: _gratitude2Controller,
                        controller3: _gratitude3Controller,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _continue,
                          child: const Text('Continue to Badge Selection'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int number;
  final String emoji;
  final String title;
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextEditingController? controller2;
  final TextEditingController? controller3;
  final int? maxLines;

  const _QuestionCard({
    required this.number,
    required this.emoji,
    required this.title,
    required this.label,
    this.hintText,
    required this.controller,
    this.controller2,
    this.controller3,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final isGratitudes = controller2 != null && controller3 != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: VesperColors.loveOutLoudGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: context.textStyles.titleMedium?.copyWith(
                        color: VesperColors.loveOutLoudGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(title, style: context.textStyles.titleLarge)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Text(label, style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (isGratitudes) ...[
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: '1. e.g., My health',
                  prefixIcon: Icon(Icons.circle, size: 8),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller2,
                decoration: const InputDecoration(
                  hintText: '2. e.g., Time with family',
                  prefixIcon: Icon(Icons.circle, size: 8),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller3,
                decoration: const InputDecoration(
                  hintText: '3. e.g., A warm home',
                  prefixIcon: Icon(Icons.circle, size: 8),
                ),
              ),
            ] else
              TextField(
                controller: controller,
                maxLines: maxLines ?? 1,
                decoration: InputDecoration(hintText: hintText),
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeSelectionSheet extends StatefulWidget {
  final String appreciationText;
  final String winText;
  final List<String> gratitudes;

  const _BadgeSelectionSheet({
    required this.appreciationText,
    required this.winText,
    required this.gratitudes,
  });

  @override
  State<_BadgeSelectionSheet> createState() => _BadgeSelectionSheetState();
}

class _BadgeSelectionSheetState extends State<_BadgeSelectionSheet> {
  AppreciationBadge? _selectedBadge;

  Future<void> _send() async {
    if (_selectedBadge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a badge to send')),
      );
      return;
    }

    final userService = context.read<UserService>();
    final appreciationService = context.read<AppreciationService>();
    final user = userService.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in')),
      );
      return;
    }

    final appreciation = AppreciationModel(
      fromUserId: user.id,
      fromUserName: user.name,
      toUserId: null,
      toUserName: user.partnerName.trim().isEmpty ? 'Partner' : user.partnerName,
      appreciationText: widget.appreciationText,
      winText: widget.winText,
      gratitudes: widget.gratitudes,
      selectedBadge: _selectedBadge!,
    );

    await appreciationService.addAppreciation(
      appreciation,
      userService: context.read<UserService>(),
      notificationService: context.read<NotificationService>(),
    );

    if (mounted) {
      Navigator.pop(context);
      context.go('/');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appreciation sent! 💕'),
          backgroundColor: VesperColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: VesperColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('🎁', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                Text('Choose a Gift Badge', style: context.textStyles.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Send a little gift along with your appreciation',
                  style: context.textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                alignment: WrapAlignment.center,
                children: AppreciationBadge.values.map((badge) {
                  final isSelected = _selectedBadge == badge;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBadge = badge),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? VesperColors.loveOutLoudGold.withValues(alpha: 0.2)
                            : VesperColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected
                              ? VesperColors.loveOutLoudGold
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(badge.emoji, style: const TextStyle(fontSize: 36)),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            badge.label,
                            style: context.textStyles.labelSmall?.copyWith(
                              color: isSelected
                                  ? VesperColors.loveOutLoudGold
                                  : VesperColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _send,
                child: const Text('Send Appreciation'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
