import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/services/conflict_session_service.dart';
import 'package:vesper/theme.dart';

class ConflictBreathingPage extends StatefulWidget {
  static const String routePath = '/conflict/breathe';

  const ConflictBreathingPage({super.key});

  @override
  State<ConflictBreathingPage> createState() => _ConflictBreathingPageState();
}

class _ConflictBreathingPageState extends State<ConflictBreathingPage> with SingleTickerProviderStateMixin {
  static const int totalSeconds = 120;
  static const int phaseSeconds = 4;

  late final AnimationController _pulse;

  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: phaseSeconds))..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ConflictSessionService>().startNewDraft(breathingSkipped: false);
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _elapsed++);
      if (_elapsed >= totalSeconds) {
        t.cancel();
        _advance();
      }
    });
  }

  Future<void> _advance() async {
    if (!mounted) return;
    context.push('/conflict/emotions');
  }

  String get _phaseLabel {
    final cycle = (_elapsed % (phaseSeconds * 4));
    if (cycle < phaseSeconds) return 'Inhale';
    if (cycle < phaseSeconds * 2) return 'Hold';
    if (cycle < phaseSeconds * 3) return 'Exhale';
    return 'Hold';
  }

  double get _phaseProgress {
    final phase = (_elapsed % phaseSeconds);
    return (phase + 1) / phaseSeconds;
  }

  int get _remaining => (totalSeconds - _elapsed).clamp(0, totalSeconds);

  Future<void> _confirmSkip() async {
    final shouldSkip = await showModalBottomSheet<bool>(
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
              Text('Are you sure?', style: context.textStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text('Taking a breath really helps. Even 30 seconds can change the whole conversation.', style: context.textStyles.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Keep breathing'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Skip'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (shouldSkip == true) {
      try {
        await context.read<ConflictSessionService>().startNewDraft(breathingSkipped: true);
      } catch (e) {
        debugPrint('Failed to mark breathing skipped: $e');
      }
      if (!mounted) return;
      context.push('/conflict/emotions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _elapsed / totalSeconds;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              VesperColors.primary.withValues(alpha: isDark ? 0.55 : 0.18),
              VesperColors.accent.withValues(alpha: isDark ? 0.22 : 0.55),
              (isDark ? VesperColors.darkBackground : VesperColors.background),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close_rounded, color: VesperColors.primary),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _confirmSkip,
                      child: Text('Skip', style: context.textStyles.labelLarge?.copyWith(color: VesperColors.primary)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      'Before we say anything,\nlet\'s breathe together.',
                      style: context.textStyles.headlineSmall?.copyWith(height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) {
                          final t = _phaseLabel == 'Inhale'
                              ? _pulse.value
                              : _phaseLabel == 'Exhale'
                                  ? (1 - _pulse.value)
                                  : 0.5;

                          final scale = 0.85 + (t * 0.25);
                          final ringAlpha = (0.22 + (t * 0.18)).clamp(0.0, 1.0);

                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: VesperColors.primary.withValues(alpha: ringAlpha),
                                border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.22), width: 2),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_phaseLabel, style: context.textStyles.titleLarge?.copyWith(color: Colors.white)),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text('${(_phaseProgress * phaseSeconds).round()}/$phaseSeconds', style: context.textStyles.labelLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      '2:00 total • ${_formatTime(_remaining)} left',
                      style: context.textStyles.labelMedium?.copyWith(color: VesperColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: isDark ? 0.08 : 0.25),
                    valueColor: const AlwaysStoppedAnimation(VesperColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
