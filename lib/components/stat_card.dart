import 'package:flutter/material.dart';
import 'package:vesper/theme.dart';

class StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ?? VesperColors.primary;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? VesperColors.darkSurface : VesperColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark 
              ? VesperColors.darkSurfaceVariant 
              : VesperColors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: context.textStyles.headlineSmall?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
