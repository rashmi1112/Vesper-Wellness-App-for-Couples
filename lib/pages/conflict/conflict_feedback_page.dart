import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/models/conflict_session_model.dart';
import 'package:vesper/models/in_app_notification_model.dart';
import 'package:vesper/services/conflict_session_service.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/theme.dart';

class ConflictFeedbackPage extends StatefulWidget {
  static const String routePath = '/conflict/feedback';

  const ConflictFeedbackPage({super.key});

  @override
  State<ConflictFeedbackPage> createState() => _ConflictFeedbackPageState();
}

class _ConflictFeedbackPageState extends State<ConflictFeedbackPage> {
  int _rating = 4;
  bool _aiSummary = true;
  final _notesController = TextEditingController();
  final _followUpController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  String _generateSummary(ConflictSessionModel draft) {
    final emotions = draft.emotions.isEmpty ? 'some tough feelings' : draft.emotions.join(', ').toLowerCase();
    final needs = draft.needs.isEmpty ? 'support and care' : draft.needs.take(3).join(', ').toLowerCase();
    final trigger = draft.triggerText.trim().isEmpty ? 'a moment that felt activating' : draft.triggerText.trim();

    return 'Summary: You felt $emotions. The trigger was “$trigger”. Right now you need $needs. Next time, try naming the feeling first, then making one clear request.';
  }

  Future<void> _closeSession() async {
    final service = context.read<ConflictSessionService>();
    final draft = service.draft;
    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session not found.')));
      return;
    }

    final followUpDays = int.tryParse(_followUpController.text.trim());
    final summary = _aiSummary ? _generateSummary(draft) : '';

    try {
      await service.closeDraftAsResolved(
        rating: _rating,
        notes: _notesController.text.trim(),
        aiSummaryEnabled: _aiSummary,
        aiSummaryText: summary,
        followUpInDays: followUpDays,
      );

      await context.read<NotificationService>().add(
            InAppNotificationModel(
              type: InAppNotificationType.system,
              title: 'Conflict session saved',
              body: 'Nice work showing up with care. You can revisit this in History → Conflict.',
            ),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conflict session saved! 🤝'),
          backgroundColor: VesperColors.success,
        ),
      );
      context.go('/history');
    } catch (e) {
      debugPrint('Failed to close session: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save session: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draft = context.watch<ConflictSessionService>().draft;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded, color: VesperColors.primary)),
        title: Text('Feedback', style: context.textStyles.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How did that go?', style: context.textStyles.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rating', style: context.textStyles.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          for (int i = 1; i <= 5; i++)
                            IconButton(
                              onPressed: () => setState(() => _rating = i),
                              icon: Icon(i <= _rating ? Icons.star_rounded : Icons.star_border_rounded, color: VesperColors.warning),
                            ),
                          const Spacer(),
                          Text('$_rating/5', style: context.textStyles.labelLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Anything you want to note about this session? (optional)'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: (isDark ? VesperColors.darkSurfaceVariant : VesperColors.surfaceVariant).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: VesperColors.accent.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AI summary', style: context.textStyles.titleMedium),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text('Generates a gentle recap from your notes (local template for now).', style: context.textStyles.bodySmall),
                                ],
                              ),
                            ),
                            Switch(value: _aiSummary, onChanged: (v) => setState(() => _aiSummary = v), activeColor: VesperColors.primary),
                          ],
                        ),
                      ),
                      if (_aiSummary && draft != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(_generateSummary(draft), style: context.textStyles.bodyMedium),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _followUpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Save a reminder for a follow-up in X days (optional)'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _closeSession,
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                  label: const Text('Close this session', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
