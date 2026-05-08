import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/models/conflict_session_model.dart';
import 'package:vesper/services/conflict_session_service.dart';
import 'package:vesper/theme.dart';

class ConflictFrameworkPage extends StatefulWidget {
  static const String routePath = '/conflict/framework';

  const ConflictFrameworkPage({super.key});

  @override
  State<ConflictFrameworkPage> createState() => _ConflictFrameworkPageState();
}

class _ConflictFrameworkPageState extends State<ConflictFrameworkPage> {
  bool _recording = false;
  final _notesController = TextEditingController();

  final List<_FrameworkStep> _steps = const [
    _FrameworkStep(title: 'Acknowledge', body: 'Start by acknowledging that your partner is hurting too, even if you see it differently.'),
    _FrameworkStep(title: 'Share', body: 'Use your notes from earlier to share what you felt and why, without blame.'),
    _FrameworkStep(title: 'Listen', body: 'Let your partner speak fully without interrupting. Then reflect back what you heard.'),
    _FrameworkStep(title: 'What went wrong', body: 'Together, identify the key moment where things escalated.'),
    _FrameworkStep(title: 'What we need', body: 'Share what you each need going forward.'),
    _FrameworkStep(title: 'What we will do differently', body: 'Agree on one specific thing each of you will try next time.'),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final service = context.read<ConflictSessionService>();
    final draft = service.draft;
    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session not found.')));
      return;
    }

    try {
      await service.updateDraft(draft.copyWith(conversationNotes: _notesController.text.trim()));
    } catch (e) {
      debugPrint('Failed to save framework notes: $e');
    }

    if (!mounted) return;
    context.push('/conflict/feedback');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded, color: VesperColors.primary)),
        title: Text('Conversation Framework', style: context.textStyles.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Optional voice recording', style: context.textStyles.titleMedium),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Recording requires a native plugin + permissions, so it\'s UI-only for now.', style: context.textStyles.bodySmall),
                          ],
                        ),
                      ),
                      Switch(
                        value: _recording,
                        onChanged: (v) => setState(() => _recording = v),
                        activeColor: VesperColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Use these steps like a gentle script.', style: context.textStyles.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              _FrameworkAccordion(steps: _steps),
              const SizedBox(height: AppSpacing.lg),
              Text('Notes (optional)', style: context.textStyles.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _notesController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Key moments, agreements, anything you want to remember'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: (isDark ? VesperColors.darkSurfaceVariant : VesperColors.surfaceVariant).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: VesperColors.accent.withValues(alpha: 0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.favorite_rounded, color: VesperColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text('Tiny rule: no “always” or “never”. Just this moment, and what we can do next.', style: context.textStyles.bodyMedium)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _continue,
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text('We\'re ready for feedback', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrameworkAccordion extends StatefulWidget {
  final List<_FrameworkStep> steps;

  const _FrameworkAccordion({required this.steps});

  @override
  State<_FrameworkAccordion> createState() => _FrameworkAccordionState();
}

class _FrameworkAccordionState extends State<_FrameworkAccordion> {
  final Set<int> _open = {0};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: VesperColors.accent.withValues(alpha: 0.35)),
        color: isDark ? VesperColors.darkSurface : VesperColors.surface,
      ),
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        elevation: 0,
        dividerColor: (isDark ? VesperColors.darkSurfaceVariant : VesperColors.accent).withValues(alpha: 0.35),
        expansionCallback: (index, isExpanded) {
          setState(() {
            if (isExpanded) {
              _open.remove(index);
            } else {
              _open.add(index);
            }
          });
        },
        children: [
          for (int i = 0; i < widget.steps.length; i++)
            ExpansionPanel(
              canTapOnHeader: true,
              backgroundColor: Colors.transparent,
              headerBuilder: (context, isExpanded) {
                final step = widget.steps[i];
                return ListTile(
                  title: Text(step.title, style: context.textStyles.titleMedium),
                  subtitle: Text('Tap to expand', style: context.textStyles.labelSmall),
                );
              },
              body: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: Text(widget.steps[i].body, style: context.textStyles.bodyMedium?.copyWith(height: 1.5)),
              ),
              isExpanded: _open.contains(i),
            ),
        ],
      ),
    );
  }
}

class _FrameworkStep {
  final String title;
  final String body;

  const _FrameworkStep({required this.title, required this.body});
}
