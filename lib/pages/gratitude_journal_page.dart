import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vesper/components/wellness_card.dart';
import 'package:vesper/models/gratitude_entry_model.dart';
import 'package:vesper/services/gratitude_service.dart';
import 'package:vesper/theme.dart';

class GratitudeJournalPage extends StatefulWidget {
  const GratitudeJournalPage({super.key});

  @override
  State<GratitudeJournalPage> createState() => _GratitudeJournalPageState();
}

class _GratitudeJournalPageState extends State<GratitudeJournalPage> {
  void _showAddEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddGratitudeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gratitudeService = context.watch<GratitudeService>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Gratitude Journal',
          style: context.textStyles.titleLarge,
        ),
      ),
      body: gratitudeService.entries.isEmpty
          ? _buildEmptyState()
          : _buildEntriesList(gratitudeService),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntrySheet,
        backgroundColor: VesperColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Gratitude', style: TextStyle(color: Colors.white)),
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
            const Text('🙏', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Start Your Gratitude Journey',
              style: context.textStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Record moments of appreciation to strengthen your bond and cultivate positivity in your relationship.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _showAddEntrySheet,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Your First Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesList(GratitudeService service) {
    final groupedEntries = _groupEntriesByDate(service.entries);
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final group = groupedEntries[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                group.title,
                style: context.textStyles.titleMedium?.copyWith(
                  color: VesperColors.textSecondary,
                ),
              ),
            ),
            ...group.entries.map((entry) => _GratitudeEntryCard(
              entry: entry,
              onDelete: () {
                service.deleteEntry(entry.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry deleted')),
                );
              },
            )),
          ],
        );
      },
    );
  }

  List<_EntryGroup> _groupEntriesByDate(List<GratitudeEntryModel> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    final groups = <_EntryGroup>[];
    final todayEntries = <GratitudeEntryModel>[];
    final yesterdayEntries = <GratitudeEntryModel>[];
    final thisWeekEntries = <GratitudeEntryModel>[];
    final olderEntries = <GratitudeEntryModel>[];

    for (final entry in entries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (entryDate.isAtSameMomentAs(today)) {
        todayEntries.add(entry);
      } else if (entryDate.isAtSameMomentAs(yesterday)) {
        yesterdayEntries.add(entry);
      } else if (entryDate.isAfter(thisWeek)) {
        thisWeekEntries.add(entry);
      } else {
        olderEntries.add(entry);
      }
    }

    if (todayEntries.isNotEmpty) groups.add(_EntryGroup('Today', todayEntries));
    if (yesterdayEntries.isNotEmpty) groups.add(_EntryGroup('Yesterday', yesterdayEntries));
    if (thisWeekEntries.isNotEmpty) groups.add(_EntryGroup('This Week', thisWeekEntries));
    if (olderEntries.isNotEmpty) groups.add(_EntryGroup('Earlier', olderEntries));

    return groups;
  }
}

class _EntryGroup {
  final String title;
  final List<GratitudeEntryModel> entries;

  _EntryGroup(this.title, this.entries);
}

class _GratitudeEntryCard extends StatelessWidget {
  final GratitudeEntryModel entry;
  final VoidCallback onDelete;

  const _GratitudeEntryCard({
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key(entry.id),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(entry.categoryEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm),
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
                      entry.category,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: VesperColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('h:mm a').format(entry.date),
                    style: context.textStyles.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                entry.content,
                style: context.textStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddGratitudeSheet extends StatefulWidget {
  const _AddGratitudeSheet();

  @override
  State<_AddGratitudeSheet> createState() => _AddGratitudeSheetState();
}

class _AddGratitudeSheetState extends State<_AddGratitudeSheet> {
  final _contentController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitEntry() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write what you\'re grateful for')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<GratitudeService>().addEntry(
        content: _contentController.text,
        category: _selectedCategory!,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gratitude recorded! 🙏'),
            backgroundColor: VesperColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save entry')),
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
    final gratitudeService = context.read<GratitudeService>();
    
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
              'What are you grateful for?',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Express appreciation for your partner',
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _contentController,
              maxLines: 4,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'I\'m grateful for...',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Category',
              style: context.textStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: gratitudeService.categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
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
                    child: Text(
                      category,
                      style: context.textStyles.labelMedium?.copyWith(
                        color: isSelected ? Colors.white : VesperColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEntry,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Entry'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
