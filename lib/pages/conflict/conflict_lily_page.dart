import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/models/conflict_session_model.dart';
import 'package:vesper/models/in_app_notification_model.dart';
import 'package:vesper/services/conflict_session_service.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/theme.dart';

class ConflictLilyPage extends StatefulWidget {
  static const String routePath = '/conflict/lily';

  const ConflictLilyPage({super.key});

  @override
  State<ConflictLilyPage> createState() => _ConflictLilyPageState();
}

class _ConflictLilyPageState extends State<ConflictLilyPage> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  bool _waiting = false;
  Timer? _nudgeTimer;
  bool _showNudge = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    _nudgeTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendLily() async {
    final sessionService = context.read<ConflictSessionService>();
    final draft = sessionService.draft;
    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start the session first.')));
      return;
    }

    // Send peace lily notification to partner(s)
    try {
      final userService = context.read<UserService>();
      final notificationService = context.read<NotificationService>();
      final currentUser = userService.currentUser;

      if (currentUser != null && currentUser.partnerIds.isNotEmpty) {
        for (final partnerId in currentUser.partnerIds) {
          final partner = await userService.findUserById(partnerId);
          if (partner != null && partner.peaceLilyNotificationsEnabled) {
            await notificationService.createPeaceLilyNotification(
              recipientUserId: partnerId,
              senderName: currentUser.name,
              sessionId: draft.id,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to send peace lily notification: $e');
    }

    if (!mounted) return;

    final response = await showModalBottomSheet<ConflictPartnerResponse>(
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
              Text('Simulate partner response', style: context.textStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Push notifications + real partner responses need Firebase/Supabase. For now you can simulate the reply to see the flow.',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(ConflictPartnerResponse.readyToo),
                  child: const Text('I am ready too (send cookies back)'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(ConflictPartnerResponse.needsMoreTime),
                  child: const Text('I need a little more time'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (response == null) return;

    try {
      await sessionService.updateDraft(draft.copyWith(partnerResponse: response));
    } catch (e) {
      debugPrint('Failed to persist partner response: $e');
    }

    if (!mounted) return;

    if (response == ConflictPartnerResponse.readyToo) {
      context.push('/conflict/framework');
    } else {
      setState(() => _waiting = true);
      _startNudgeTimer();
    }
  }

  void _startNudgeTimer() {
    _nudgeTimer?.cancel();
    _showNudge = false;
    _nudgeTimer = Timer(const Duration(minutes: 30), () {
      if (!mounted) return;
      setState(() => _showNudge = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded, color: VesperColors.primary)),
        title: Text('Peace Signal', style: context.textStyles.titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_anim.value);
                    return Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              VesperColors.accent.withValues(alpha: isDark ? 0.22 : 0.65),
                              VesperColors.primary.withValues(alpha: 0.25 + (t * 0.10)),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.local_florist_rounded, size: 84, color: VesperColors.primary.withValues(alpha: 0.85)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(
                _waiting ? 'Your partner will reach out when they are ready.' : 'Send your partner a gentle signal that you are ready to connect.',
                style: context.textStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _waiting ? 'Take care of yourself until then.' : 'No arguments, no paragraphs. Just a soft “I\'m here.”',
                style: context.textStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!_waiting)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendLily,
                    icon: const Icon(Icons.local_florist_rounded, color: Colors.white),
                    label: const Text('Send a Lily', style: TextStyle(color: Colors.white)),
                  ),
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to Home'),
                  ),
                ),
                if (_showNudge) ...[
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gentle nudge', style: context.textStyles.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'It looks like you are both waiting. Someone has to go first. Want to send the lily again?',
                            style: context.textStyles.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _waiting = false);
                                _sendLily();
                              },
                              child: const Text('Send Lily Again'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
