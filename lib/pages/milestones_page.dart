import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vesper/components/wellness_card.dart';
import 'package:vesper/models/milestone_model.dart';
import 'package:vesper/services/milestone_service.dart';
import 'package:vesper/theme.dart';

class MilestonesPage extends StatefulWidget {
  const MilestonesPage({super.key});

  @override
  State<MilestonesPage> createState() => _MilestonesPageState();
}

class _MilestonesPageState extends State<MilestonesPage> {
  void _showAddMilestoneSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddMilestoneSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final milestoneService = context.watch<MilestoneService>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Milestones',
          style: context.textStyles.titleLarge,
        ),
      ),
      body: milestoneService.milestones.isEmpty
          ? _buildEmptyState()
          : _buildMilestonesList(milestoneService),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMilestoneSheet,
        backgroundColor: VesperColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Milestone', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Celebrate Your Journey',
              style: context.textStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Record important dates and milestones in your relationship to never forget the special moments.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _showAddMilestoneSheet,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Your First Milestone'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesList(MilestoneService service) {
    final sortedMilestones = List<MilestoneModel>.from(service.milestones)
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (service.upcomingMilestones.isNotEmpty) ...[
          Text(
            'Coming Up',
            style: context.textStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ...service.upcomingMilestones.map((milestone) => _MilestoneCard(
            milestone: milestone,
            isUpcoming: true,
            onDelete: () => service.deleteMilestone(milestone.id),
          )),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          'All Milestones',
          style: context.textStyles.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ...sortedMilestones.map((milestone) => _MilestoneCard(
          milestone: milestone,
          onDelete: () => service.deleteMilestone(milestone.id),
        )),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final MilestoneModel milestone;
  final bool isUpcoming;
  final VoidCallback onDelete;

  const _MilestoneCard({
    required this.milestone,
    this.isUpcoming = false,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key(milestone.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          decoration: BoxDecoration(
            color: VesperColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(Icons.delete_outline, color: VesperColors.error),
        ),
        child: WellnessCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? VesperColors.primary.withValues(alpha: 0.1)
                      : VesperColors.accent.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  milestone.typeEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
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
                            milestone.typeLabel,
                            style: context.textStyles.labelSmall?.copyWith(
                              color: VesperColors.primary,
                            ),
                          ),
                        ),
                        if (milestone.yearsAgo > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${milestone.yearsAgo} ${milestone.yearsAgo == 1 ? "year" : "years"} ago',
                            style: context.textStyles.labelSmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      milestone.title,
                      style: context.textStyles.titleMedium,
                    ),
                    if (milestone.description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        milestone.description!,
                        style: context.textStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateFormat('MMMM d, yyyy').format(milestone.date),
                      style: context.textStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${milestone.daysUntil}',
                    style: context.textStyles.headlineMedium?.copyWith(
                      color: milestone.daysUntil <= 30 
                          ? VesperColors.primary 
                          : VesperColors.textSecondary,
                    ),
                  ),
                  Text(
                    'days',
                    style: context.textStyles.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMilestoneSheet extends StatefulWidget {
  const _AddMilestoneSheet();

  @override
  State<_AddMilestoneSheet> createState() => _AddMilestoneSheetState();
}

class _AddMilestoneSheetState extends State<_AddMilestoneSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  MilestoneType _selectedType = MilestoneType.anniversary;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: VesperColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitMilestone() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final milestone = MilestoneModel(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : null,
        date: _selectedDate,
        type: _selectedType,
      );

      await context.read<MilestoneService>().addMilestone(milestone);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Milestone added! 🎉'),
            backgroundColor: VesperColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save milestone')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: VesperColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Add a Milestone',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Celebrate the special moments in your journey',
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Our Anniversary',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'A special memory...',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Type',
              style: context.textStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: MilestoneType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? VesperColors.primary 
                          : VesperColors.accent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getTypeEmoji(type), style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeLabel(type),
                          style: context.textStyles.labelMedium?.copyWith(
                            color: isSelected ? Colors.white : VesperColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Date',
              style: context.textStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: VesperColors.accent),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: VesperColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      DateFormat('MMMM d, yyyy').format(_selectedDate),
                      style: context.textStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitMilestone,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Milestone'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String _getTypeEmoji(MilestoneType type) {
    switch (type) {
      case MilestoneType.anniversary: return '💍';
      case MilestoneType.firstDate: return '💕';
      case MilestoneType.engagement: return '💎';
      case MilestoneType.wedding: return '👰';
      case MilestoneType.travel: return '✈️';
      case MilestoneType.achievement: return '🏆';
      case MilestoneType.custom: return '⭐';
    }
  }

  String _getTypeLabel(MilestoneType type) {
    switch (type) {
      case MilestoneType.anniversary: return 'Anniversary';
      case MilestoneType.firstDate: return 'First Date';
      case MilestoneType.engagement: return 'Engagement';
      case MilestoneType.wedding: return 'Wedding';
      case MilestoneType.travel: return 'Travel';
      case MilestoneType.achievement: return 'Achievement';
      case MilestoneType.custom: return 'Custom';
    }
  }
}
