import 'package:flutter/material.dart';
import 'package:vesper/models/date_idea_model.dart';
import 'package:vesper/theme.dart';

class DateIdeaCard extends StatelessWidget {
  final DateIdeaModel dateIdea;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const DateIdeaCard({
    super.key,
    required this.dateIdea,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? VesperColors.darkSurface : VesperColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark 
                ? VesperColors.darkSurfaceVariant 
                : VesperColors.accent.withValues(alpha: 0.3),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateIdea.imageAsset != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  dateIdea.imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: VesperColors.accent.withValues(alpha: 0.3),
                    child: const Center(
                      child: Text('💕', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: VesperColors.accent.withValues(alpha: 0.3),
                  child: Center(
                    child: Text(
                      dateIdea.categoryEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: VesperColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${dateIdea.categoryEmoji} ${dateIdea.categoryLabel}',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: VesperColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (dateIdea.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: VesperColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: VesperColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Done',
                                style: context.textStyles.labelSmall?.copyWith(
                                  color: VesperColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    dateIdea.title,
                    style: context.textStyles.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateIdea.description,
                    style: context.textStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.access_time_outlined,
                        label: dateIdea.timeLabel,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _InfoChip(
                        icon: Icons.attach_money,
                        label: dateIdea.costLabel,
                      ),
                      const Spacer(),
                      if (!dateIdea.isCompleted && onComplete != null)
                        TextButton(
                          onPressed: onComplete,
                          style: TextButton.styleFrom(
                            foregroundColor: VesperColors.primary,
                          ),
                          child: const Text('Mark Done'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: VesperColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textStyles.labelSmall,
        ),
      ],
    );
  }
}
