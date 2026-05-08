import 'package:flutter/material.dart';
import 'package:vesper/theme.dart';

class WellnessCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? borderRadius;

  const WellnessCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? VesperColors.darkSurface : VesperColors.surface),
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
          border: Border.all(
            color: isDark 
                ? VesperColors.darkSurfaceVariant 
                : VesperColors.accent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class GradientWellnessCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const GradientWellnessCard({
    super.key,
    required this.child,
    this.padding,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors ?? [
              VesperColors.primary,
              VesperColors.primaryLight,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: child,
      ),
    );
  }
}
