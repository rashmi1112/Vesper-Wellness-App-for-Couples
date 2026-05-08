import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/models/conflict_session_model.dart';
import 'package:vesper/services/conflict_session_service.dart';
import 'package:vesper/theme.dart';

class ConflictEmotionCheckInPage extends StatefulWidget {
  static const String routePath = '/conflict/emotions';

  const ConflictEmotionCheckInPage({super.key});

  @override
  State<ConflictEmotionCheckInPage> createState() => _ConflictEmotionCheckInPageState();
}

class _ConflictEmotionCheckInPageState extends State<ConflictEmotionCheckInPage> {
  final _formKey = GlobalKey<FormState>();

  final _emotionTextController = TextEditingController();
  final _triggerController = TextEditingController();
  final _pastPatternController = TextEditingController();

  bool _pastPattern = false;
  ConflictReadiness _readiness = ConflictReadiness.notYet;

  final Set<String> _emotions = {};
  final Set<String> _needs = {};

  static const emotions = [
    'Angry',
    'Hurt',
    'Scared',
    'Sad',
    'Frustrated',
    'Overwhelmed',
    'Anxious',
    'Confused',
    'Disappointed',
    'Numb',
  ];

  static const needs = [
    'Space and time alone',
    'To be heard without judgment',
    'A hug or physical comfort',
    'Help solving the problem',
    'Acknowledgment that I was hurt',
    'Time before we talk',
    'To talk it through now',
    'I am not sure yet',
  ];

  @override
  void dispose() {
    _emotionTextController.dispose();
    _triggerController.dispose();
    _pastPatternController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (_emotions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick at least one emotion.')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final service = context.read<ConflictSessionService>();
    final draft = service.draft ?? ConflictSessionModel();

    final updated = draft.copyWith(
      emotions: _emotions.toList(),
      emotionFreeText: _emotionTextController.text.trim(),
      triggerText: _triggerController.text.trim(),
      connectedToPastPattern: _pastPattern,
      pastPatternText: _pastPattern ? _pastPatternController.text.trim() : '',
      needs: _needs.toList(),
      readiness: _readiness,
    );

    try {
      await service.updateDraft(updated);
    } catch (e) {
      debugPrint('Failed to save emotion check-in: $e');
    }

    if (!mounted) return;

    if (_readiness == ConflictReadiness.initiateNow) {
      context.push('/conflict/lily');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('That\'s okay.', style: context.textStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _readiness == ConflictReadiness.wantPartnerToReachOut
                    ? 'We\'ll gently let your partner know you\'d like them to reach out first (push requires backend).'
                    : 'You\'ve captured what you\'re feeling. Come back when you\'re ready to talk.',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Stay here'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/');
                      },
                      child: const Text('Back to Home'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded, color: VesperColors.primary)),
        title: Text('Emotion Check-In', style: context.textStyles.titleLarge),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: 'How are you feeling right now?', subtitle: 'Pick as many as you need.'),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final e in emotions)
                      FilterChip(
                        selected: _emotions.contains(e),
                        label: Text(e),
                        onSelected: (v) => setState(() => v ? _emotions.add(e) : _emotions.remove(e)),
                        labelStyle: context.textStyles.labelMedium?.copyWith(
                          color: _emotions.contains(e) ? Colors.white : (isDark ? VesperColors.darkTextPrimary : VesperColors.textPrimary),
                        ),
                        selectedColor: VesperColors.primary,
                        backgroundColor: isDark ? VesperColors.darkSurfaceVariant : VesperColors.surfaceVariant,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: VesperColors.accent.withValues(alpha: 0.35))),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emotionTextController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Describe it in your own words (optional)'),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(title: 'What do you think triggered this feeling?'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _triggerController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Trigger / what happened'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'A short note is enough.' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? VesperColors.darkSurface : VesperColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: VesperColors.accent.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _pastPattern,
                        onChanged: (v) => setState(() => _pastPattern = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Was this connected to a past experience or pattern?', style: context.textStyles.bodyLarge?.copyWith(color: isDark ? VesperColors.darkTextPrimary : VesperColors.textPrimary)),
                      ),
                      if (_pastPattern) ...[
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _pastPatternController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'If yes, what pattern does it touch?'),
                          validator: (v) => !_pastPattern ? null : (v == null || v.trim().isEmpty) ? 'Add a quick note.' : null,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(title: 'What do you need right now?'),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        for (final n in needs)
                          CheckboxListTile(
                            value: _needs.contains(n),
                            onChanged: (v) => setState(() => v == true ? _needs.add(n) : _needs.remove(n)),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            title: Text(n, style: context.textStyles.bodyLarge?.copyWith(color: isDark ? VesperColors.darkTextPrimary : VesperColors.textPrimary)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(title: 'Are you ready to talk to your partner?'),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        RadioListTile(
                          value: ConflictReadiness.initiateNow,
                          groupValue: _readiness,
                          onChanged: (v) => setState(() => _readiness = v ?? ConflictReadiness.notYet),
                          title: Text('Yes, I want to initiate the conversation', style: context.textStyles.bodyLarge?.copyWith(color: isDark ? VesperColors.darkTextPrimary : VesperColors.textPrimary)),
                        ),
                        RadioListTile(
                          value: ConflictReadiness.notYet,
                          groupValue: _readiness,
                          onChanged: (v) => setState(() => _readiness = v ?? ConflictReadiness.notYet),
                          title: Text('Not yet, I need more time', style: context.textStyles.bodyLarge?.copyWith(color: isDark ? VesperColors.darkTextPrimary : VesperColors.textPrimary)),
                        ),
                        RadioListTile(
                          value: ConflictReadiness.wantPartnerToReachOut,
                          groupValue: _readiness,
                          onChanged: (v) => setState(() => _readiness = v ?? ConflictReadiness.notYet),
                          title: Text('I would like my partner to reach out to me first', style: context.textStyles.bodyLarge?.copyWith(color: isDark ? VesperColors.darkTextPrimary : VesperColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _continue,
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    label: const Text('Continue', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textStyles.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle!, style: context.textStyles.bodyMedium),
        ],
      ],
    );
  }
}
