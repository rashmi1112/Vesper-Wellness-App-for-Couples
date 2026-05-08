import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vesper/components/wellness_card.dart';
import 'package:vesper/services/conversation_service.dart';
import 'package:vesper/theme.dart';

class ConversationStartersPage extends StatefulWidget {
  const ConversationStartersPage({super.key});

  @override
  State<ConversationStartersPage> createState() => _ConversationStartersPageState();
}

class _ConversationStartersPageState extends State<ConversationStartersPage> {
  String? _selectedCategory;
  late ConversationPrompt _currentPrompt;

  @override
  void initState() {
    super.initState();
    _currentPrompt = context.read<ConversationService>().getRandomPrompt();
  }

  void _getNewPrompt() {
    final service = context.read<ConversationService>();
    setState(() {
      _currentPrompt = service.getRandomPrompt(_selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationService = context.watch<ConversationService>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Conversation Starters',
          style: context.textStyles.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spark meaningful conversations',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Use these prompts to deepen your connection',
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildCategoryChips(conversationService),
            const SizedBox(height: AppSpacing.xl),
            _buildPromptCard(),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _getNewPrompt,
                icon: const Icon(Icons.refresh, color: VesperColors.primary),
                label: const Text('Get Another Prompt'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildAllPromptsList(conversationService),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ConversationService service) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: _selectedCategory == null,
            onTap: () {
              setState(() => _selectedCategory = null);
              _getNewPrompt();
            },
          ),
          ...service.categories.map((category) => _CategoryChip(
            label: category,
            isSelected: _selectedCategory == category,
            onTap: () {
              setState(() => _selectedCategory = category);
              _getNewPrompt();
            },
          )),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_currentPrompt.question),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              VesperColors.primary,
              VesperColors.primaryLight,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          children: [
            Text(
              _currentPrompt.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _currentPrompt.category,
              style: context.textStyles.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _currentPrompt.question,
              style: context.textStyles.headlineSmall?.copyWith(
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPromptsList(ConversationService service) {
    final prompts = _selectedCategory != null
        ? service.getPromptsByCategory(_selectedCategory!)
        : service.allPrompts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedCategory != null 
              ? '$_selectedCategory Prompts' 
              : 'All Prompts',
          style: context.textStyles.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ...prompts.map((prompt) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: WellnessCard(
            onTap: () {
              setState(() => _currentPrompt = prompt);
            },
            child: Row(
              children: [
                Text(prompt.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prompt.category,
                        style: context.textStyles.labelSmall?.copyWith(
                          color: VesperColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        prompt.question,
                        style: context.textStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
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
          child: Text(
            label,
            style: context.textStyles.labelMedium?.copyWith(
              color: isSelected ? Colors.white : VesperColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
