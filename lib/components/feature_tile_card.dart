import 'package:flutter/material.dart';
import 'package:vesper/theme.dart';

class FeatureTileCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const FeatureTileCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? VesperColors.darkSurface : VesperColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: accentColor.withValues(alpha: isDark ? 0.25 : 0.22), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textStyles.titleLarge?.copyWith(color: isDark ? VesperColors.darkTextPrimary : VesperColors.textPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description, style: context.textStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text('Open', style: context.textStyles.labelLarge?.copyWith(color: accentColor)),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.arrow_forward_rounded, color: accentColor, size: 18),
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
