import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/components/date_idea_card.dart';
import 'package:vesper/models/date_idea_model.dart';
import 'package:vesper/services/date_idea_service.dart';
import 'package:vesper/theme.dart';

class DateIdeasPage extends StatefulWidget {
  const DateIdeasPage({super.key});

  @override
  State<DateIdeasPage> createState() => _DateIdeasPageState();
}

class _DateIdeasPageState extends State<DateIdeasPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRandomDateIdea(BuildContext context, DateIdeaService service) {
    final randomIdea = service.getRandomIdea(_selectedCategory);
    if (randomIdea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No date ideas available!')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RandomDateIdeaSheet(dateIdea: randomIdea),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateIdeaService = context.watch<DateIdeaService>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Date Ideas',
          style: context.textStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined, color: VesperColors.primary),
            onPressed: () => _showRandomDateIdea(context, dateIdeaService),
            tooltip: 'Random Date',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TabBar(
              controller: _tabController,
              labelColor: VesperColors.primary,
              unselectedLabelColor: VesperColors.textSecondary,
              indicatorColor: VesperColors.primary,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'Ideas (${dateIdeaService.incompleteDateIdeas.length})'),
                Tab(text: 'Completed (${dateIdeaService.completedCount})'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildCategoryFilter(),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDateIdeasList(dateIdeaService.incompleteDateIdeas, dateIdeaService),
                _buildDateIdeasList(dateIdeaService.completedDateIdeas, dateIdeaService),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRandomDateIdea(context, dateIdeaService),
        backgroundColor: VesperColors.primary,
        icon: const Icon(Icons.casino, color: Colors.white),
        label: const Text('Surprise Me!', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _CategoryFilterChip(
            label: 'All',
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...DateCategory.values.map((category) => _CategoryFilterChip(
            label: _getCategoryLabel(category),
            emoji: _getCategoryEmoji(category),
            isSelected: _selectedCategory == category,
            onTap: () => setState(() => _selectedCategory = category),
          )),
        ],
      ),
    );
  }

  Widget _buildDateIdeasList(List<DateIdeaModel> ideas, DateIdeaService service) {
    final filteredIdeas = _selectedCategory != null
        ? ideas.where((d) => d.category == _selectedCategory).toList()
        : ideas;

    if (filteredIdeas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💕', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No date ideas here yet',
              style: context.textStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start exploring and making memories!',
              style: context.textStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: filteredIdeas.length,
      itemBuilder: (context, index) {
        final idea = filteredIdeas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: DateIdeaCard(
            dateIdea: idea,
            onComplete: idea.isCompleted ? null : () {
              service.markAsCompleted(idea.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Marked "${idea.title}" as done! 🎉'),
                  backgroundColor: VesperColors.success,
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getCategoryLabel(DateCategory category) {
    switch (category) {
      case DateCategory.romantic: return 'Romantic';
      case DateCategory.adventure: return 'Adventure';
      case DateCategory.cozy: return 'Cozy';
      case DateCategory.creative: return 'Creative';
      case DateCategory.foodie: return 'Foodie';
      case DateCategory.outdoor: return 'Outdoor';
    }
  }

  String _getCategoryEmoji(DateCategory category) {
    switch (category) {
      case DateCategory.romantic: return '💕';
      case DateCategory.adventure: return '🎢';
      case DateCategory.cozy: return '🛋️';
      case DateCategory.creative: return '🎨';
      case DateCategory.foodie: return '🍽️';
      case DateCategory.outdoor: return '🌿';
    }
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
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
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: context.textStyles.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : VesperColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RandomDateIdeaSheet extends StatelessWidget {
  final DateIdeaModel dateIdea;

  const _RandomDateIdeaSheet({required this.dateIdea});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: VesperColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('🎲', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your Date Idea',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            DateIdeaCard(dateIdea: dateIdea),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Try Another'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Great choice! Have fun! 💕'),
                          backgroundColor: VesperColors.success,
                        ),
                      );
                    },
                    child: const Text('Let\'s Do It!'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
