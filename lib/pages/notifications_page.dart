import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/models/in_app_notification_model.dart';
import 'package:vesper/theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  IconData _iconForType(InAppNotificationType type) {
    switch (type) {
      case InAppNotificationType.peaceLilyReceived:
        return Icons.local_florist_rounded;
      case InAppNotificationType.appreciationPrompt:
        return Icons.auto_awesome_rounded;
      case InAppNotificationType.growthReminder:
        return Icons.event_rounded;
      case InAppNotificationType.streakCelebration:
        return Icons.celebration_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Notifications', style: context.textStyles.headlineSmall),
                const Spacer(),
                TextButton(
                  onPressed: service.items.isEmpty ? null : () => service.markAllRead(),
                  child: const Text('Mark all read'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: service.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : service.items.isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                          itemCount: service.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final n = service.items[index];
                            final ts = DateFormat('MMM d • h:mm a').format(n.createdAt);
                            return GestureDetector(
                              onTap: () => service.markRead(n.id, isRead: true),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: VesperColors.accent.withValues(alpha: 0.35),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(_iconForType(n.type), color: VesperColors.primary),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    n.title,
                                                    style: context.textStyles.titleMedium?.copyWith(
                                                      color: n.isRead ? null : VesperColors.textPrimary,
                                                      fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                                if (!n.isRead)
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: const BoxDecoration(color: VesperColors.primary, shape: BoxShape.circle),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSpacing.xs),
                                            Text(n.body, style: context.textStyles.bodyMedium),
                                            const SizedBox(height: AppSpacing.sm),
                                            Text(ts, style: context.textStyles.labelSmall),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off_rounded, size: 44, color: VesperColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text('All quiet for now', style: context.textStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text('When something sweet happens, you\'ll see it here.', style: context.textStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
