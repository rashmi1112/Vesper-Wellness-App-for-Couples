import 'package:flutter/material.dart';
import 'package:vesper/theme.dart';

class ConnectionSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ConnectionSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Connection Level',
              style: context.textStyles.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getScoreColor(value).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Text(
                '$value/10',
                style: context.textStyles.labelLarge?.copyWith(
                  color: _getScoreColor(value),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Text('💔', style: TextStyle(fontSize: 20)),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: _getScoreColor(value),
                  inactiveTrackColor: VesperColors.accent.withValues(alpha: 0.3),
                  thumbColor: _getScoreColor(value),
                  overlayColor: _getScoreColor(value).withValues(alpha: 0.2),
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
            const Text('💕', style: TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            _getScoreLabel(value),
            style: context.textStyles.bodyMedium?.copyWith(
              color: _getScoreColor(value),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score <= 3) return VesperColors.error;
    if (score <= 5) return VesperColors.warning;
    if (score <= 7) return VesperColors.primaryLight;
    return VesperColors.success;
  }

  String _getScoreLabel(int score) {
    if (score <= 2) return 'Need some quality time together';
    if (score <= 4) return 'Could use more connection';
    if (score <= 6) return 'Feeling okay about us';
    if (score <= 8) return 'Feeling close and connected';
    return 'Deeply bonded and in love';
  }
}
