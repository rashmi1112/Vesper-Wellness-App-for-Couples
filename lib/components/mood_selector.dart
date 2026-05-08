import 'package:flutter/material.dart';
import 'package:vesper/models/check_in_model.dart';
import 'package:vesper/theme.dart';

class MoodSelector extends StatelessWidget {
  final MoodLevel? selectedMood;
  final ValueChanged<MoodLevel> onMoodSelected;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MoodLevel.values.map((mood) {
        final isSelected = selectedMood == mood;
        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected 
                  ? VesperColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected 
                    ? VesperColors.primary 
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.2 : 1.0,
                  child: Text(
                    _getMoodEmoji(mood),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _getMoodLabel(mood),
                  style: context.textStyles.labelSmall?.copyWith(
                    color: isSelected 
                        ? VesperColors.primary 
                        : VesperColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getMoodEmoji(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.veryLow: return '😔';
      case MoodLevel.low: return '😐';
      case MoodLevel.neutral: return '🙂';
      case MoodLevel.good: return '😊';
      case MoodLevel.great: return '🥰';
    }
  }

  String _getMoodLabel(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.veryLow: return 'Low';
      case MoodLevel.low: return 'Meh';
      case MoodLevel.neutral: return 'Okay';
      case MoodLevel.good: return 'Good';
      case MoodLevel.great: return 'Great';
    }
  }
}
