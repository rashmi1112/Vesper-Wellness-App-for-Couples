import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:vesper/components/wellness_card.dart';
import 'package:vesper/models/user_model.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showEditRelationshipSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _EditRelationshipSheet(),
    );
  }

  void _showCoupleSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CoupleSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final user = userService.user;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: context.textStyles.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(userService),
            const SizedBox(height: AppSpacing.xl),
            _buildCoupleSection(userService: userService, user: user),
            const SizedBox(height: AppSpacing.xl),
            _buildAboutSection(userService: userService, user: user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(UserService userService) {
    final user = userService.user;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Profile', style: context.textStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        WellnessCard(
          onTap: _showEditRelationshipSheet,
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: VesperColors.accent.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('💑', style: TextStyle(fontSize: 32))),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Set up your profile', style: context.textStyles.titleMedium),
                    if (user != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user.partnerName.trim().isEmpty ? '💕 Not linked yet' : '💕 with ${user.partnerName}',
                        style: context.textStyles.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user.partnerName.trim().isEmpty
                            ? 'Link your partner in onboarding to share together'
                            : 'Together since ${DateFormat('MMMM yyyy').format(user.anniversaryDate)}',
                        style: context.textStyles.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: VesperColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoupleSection({required UserService userService, required UserModel? user}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Couple Settings', style: context.textStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        WellnessCard(
          onTap: _showCoupleSettingsSheet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, color: VesperColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Feature Preferences', style: context.textStyles.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Toggle features and customize schedules', style: context.textStyles.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: VesperColors.textSecondary),
                ],
              ),
              if (user != null) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                _SettingsSummaryRow(icon: Icons.calendar_today, label: 'Growth Date', value: 'Day ${user.growthDateDayOfMonth} of month'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsSummaryRow(icon: Icons.auto_awesome, label: 'Appreciation', value: user.appreciationFrequency),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection({required UserService userService, required UserModel? user}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: context.textStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        WellnessCard(
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    const Text('💕', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: AppSpacing.md),
                    Text('Togetherly', style: context.textStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Version 1.0.0', style: context.textStyles.labelSmall),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Nurturing relationships,\none moment at a time.',
                      style: context.textStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingsItem(icon: Icons.favorite_outline, title: 'Made with love', subtitle: 'For couples everywhere'),
        const SizedBox(height: AppSpacing.sm),
        _SettingsItem(icon: Icons.lock_outline, title: 'Your data stays private', subtitle: 'Stored locally on your device'),
        if (user != null && !kIsWeb) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: VesperColors.accent.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.fingerprint, color: VesperColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Biometric login', style: context.textStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text('Use Face ID / fingerprint to unlock after login.', style: context.textStyles.bodySmall),
                    ],
                  ),
                ),
                Switch(
                  value: user.biometricEnabled,
                  onChanged: (v) => userService.enableBiometricsForCurrentUser(v),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WellnessCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: VesperColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textStyles.titleSmall),
                Text(subtitle, style: context.textStyles.labelSmall),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right, color: VesperColors.textSecondary),
        ],
      ),
    );
  }
}

class _SettingsSummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingsSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: VesperColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: context.textStyles.bodyMedium),
        const Spacer(),
        Text(value, style: context.textStyles.bodySmall?.copyWith(color: VesperColors.primary)),
      ],
    );
  }
}

class _EditRelationshipSheet extends StatefulWidget {
  const _EditRelationshipSheet();

  @override
  State<_EditRelationshipSheet> createState() => _EditRelationshipSheetState();
}

class _EditRelationshipSheetState extends State<_EditRelationshipSheet> {
  late TextEditingController _nameController;
  late TextEditingController _partnerNameController;
  late DateTime _anniversaryDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final userService = context.read<UserService>();
    final user = userService.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _partnerNameController = TextEditingController(text: user?.partnerName ?? '');
    _anniversaryDate = user?.anniversaryDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anniversaryDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: VesperColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _anniversaryDate = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userService = context.read<UserService>();
      final current = userService.user;
      if (current == null) throw Exception('Please create an account first');

      await userService.updateCurrentUser(
        current.copyWith(
          name: _nameController.text.trim(),
          partnerName: _partnerNameController.text.trim(),
          anniversaryDate: _anniversaryDate,
        ),
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved! 💕'), backgroundColor: VesperColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                decoration: BoxDecoration(color: VesperColors.accent, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Edit Relationship', style: context.textStyles.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text('Update your relationship details', style: context.textStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Your Name', hintText: 'Enter your name')),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: _partnerNameController, decoration: const InputDecoration(labelText: 'Partner\'s Name', hintText: 'Enter your partner\'s name')),
            const SizedBox(height: AppSpacing.lg),
            Text('Anniversary Date', style: context.textStyles.titleMedium),
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
                    Text(DateFormat('MMMM d, yyyy').format(_anniversaryDate), style: context.textStyles.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _saveProfile,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Profile'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _CoupleSettingsSheet extends StatefulWidget {
  const _CoupleSettingsSheet();

  @override
  State<_CoupleSettingsSheet> createState() => _CoupleSettingsSheetState();
}

class _CoupleSettingsSheetState extends State<_CoupleSettingsSheet> {
  late bool fightBetter;
  late bool growTogether;
  late bool loveOutLoud;
  late int growthDateDay;
  late String appreciationFreq;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserService>().user;
    fightBetter = user?.fightBetterEnabled ?? true;
    growTogether = user?.growTogetherEnabled ?? true;
    loveOutLoud = user?.loveOutLoudEnabled ?? true;
    growthDateDay = user?.growthDateDayOfMonth ?? 1;
    appreciationFreq = user?.appreciationFrequency ?? 'Weekly';
  }

  Future<void> _save() async {
    try {
      final userService = context.read<UserService>();
      final current = userService.user;
      if (current == null) throw Exception('Please log in');

      await userService.updateCurrentUser(
        current.copyWith(
          fightBetterEnabled: fightBetter,
          growTogetherEnabled: growTogether,
          loveOutLoudEnabled: loveOutLoud,
          growthDateDayOfMonth: growthDateDay,
          appreciationFrequency: appreciationFreq,
        ),
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couple settings saved'), backgroundColor: VesperColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                decoration: BoxDecoration(color: VesperColors.accent, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Couple Settings', style: context.textStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Text('Customize features and schedules for your relationship', style: context.textStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            Text('Active Features', style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _FeatureToggle(
              title: 'Fight Better',
              subtitle: 'Conflict resolution system',
              value: fightBetter,
              onChanged: (v) => setState(() => fightBetter = v),
            ),
            _FeatureToggle(
              title: 'Grow Together',
              subtitle: 'Monthly growth challenges',
              value: growTogether,
              onChanged: (v) => setState(() => growTogether = v),
            ),
            _FeatureToggle(
              title: 'Love Out Loud',
              subtitle: 'Weekly appreciation prompts',
              value: loveOutLoud,
              onChanged: (v) => setState(() => loveOutLoud = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Schedules', style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: VesperColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: VesperColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Growth Date Day', style: context.textStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<int>(
                    value: growthDateDay,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: List.generate(28, (i) => i + 1).map((day) {
                      return DropdownMenuItem(value: day, child: Text('Day $day of month'));
                    }).toList(),
                    onChanged: (v) => setState(() => growthDateDay = v ?? 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: VesperColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: VesperColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Appreciation Frequency', style: context.textStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: appreciationFreq,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'Twice Weekly', child: Text('Twice Weekly')),
                    ],
                    onChanged: (v) => setState(() => appreciationFreq = v ?? 'Weekly'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('Save Settings')),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FeatureToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: context.textStyles.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
