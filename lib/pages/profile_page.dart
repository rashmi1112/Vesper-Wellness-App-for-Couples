import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vesper/auth/supabase_auth_manager.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserService>().user;
    if (user == null) {
      return const Center(child: Text('Please log in'));
    }

    final relationshipDays = DateTime.now().difference(user.anniversaryDate).inDays;
    final relationshipYears = (relationshipDays / 365).floor();
    final relationshipMonths = ((relationshipDays % 365) / 30).floor();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Profile', style: context.textStyles.headlineSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings_rounded, color: VesperColors.primary),
                  label: Text('Settings', style: context.textStyles.labelLarge?.copyWith(color: VesperColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _Avatar(base64: user.profilePhotoBase64, fallbackText: user.name),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: context.textStyles.titleLarge),
                              const SizedBox(height: AppSpacing.xs),
                              Text(user.email, style: context.textStyles.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (relationshipYears > 0 || relationshipMonths > 0) ...[
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: VesperColors.primary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            relationshipYears > 0
                                ? '$relationshipYears ${relationshipYears == 1 ? 'year' : 'years'} together'
                                : '$relationshipMonths ${relationshipMonths == 1 ? 'month' : 'months'} together',
                            style: context.textStyles.titleMedium?.copyWith(color: VesperColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (user.partnerName.trim().isNotEmpty) ...[
              Text('Your Partner', style: context.textStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: VesperColors.accent.withValues(alpha: 0.45),
                        child: Text(
                          user.partnerName.isEmpty ? 'P' : user.partnerName.characters.first.toUpperCase(),
                          style: context.textStyles.titleMedium?.copyWith(color: VesperColors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.partnerName, style: context.textStyles.titleLarge),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Together since ${DateFormat('MMMM d, yyyy').format(user.anniversaryDate)}', style: context.textStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text('Account Settings', style: context.textStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _ProfileActionCard(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update name, email, phone, photo',
              onTap: () => _showEditProfileSheet(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileActionCard(
              icon: Icons.notifications_outlined,
              title: 'Notification Preferences',
              subtitle: 'Manage reminders and alerts',
              onTap: () => _showNotificationPrefsSheet(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Data & Privacy', style: context.textStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _ProfileActionCard(
              icon: Icons.download_outlined,
              title: 'Download Your Data',
              subtitle: 'Export all your relationship data',
              onTap: () => _showDataExportDialog(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileActionCard(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              subtitle: 'Permanently remove all data',
              iconColor: VesperColors.error,
              textColor: VesperColors.error,
              onTap: () => _showDeleteAccountDialog(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(child: Text('Togetherly', style: context.textStyles.labelSmall)),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _EditProfileSheet(),
    );
  }

  void _showNotificationPrefsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NotificationPrefsSheet(),
    );
  }

  void _showDataExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Data'),
        content: const Text('Your data is stored locally on this device. To export it, go to Settings and use the Couple Settings section.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This will permanently delete your account and all relationship data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion is not implemented in this local-only build')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: VesperColors.error)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<SupabaseAuthManager>().signOut();
              await context.read<UserService>().clearUser();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? base64;
  final String fallbackText;

  const _Avatar({required this.base64, required this.fallbackText});

  @override
  Widget build(BuildContext context) {
    final bytes = (base64 == null || base64!.isEmpty) ? null : base64Decode(base64!);
    return CircleAvatar(
      radius: 32,
      backgroundColor: VesperColors.accent.withValues(alpha: 0.45),
      foregroundImage: bytes == null ? null : MemoryImage(bytes),
      child: bytes == null
          ? Text(
              fallbackText.isEmpty ? 'Y' : fallbackText.characters.first.toUpperCase(),
              style: context.textStyles.titleLarge?.copyWith(color: VesperColors.primary),
            )
          : null,
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _ProfileActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? VesperColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.titleMedium?.copyWith(color: textColor)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: context.textStyles.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: iconColor ?? VesperColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserService>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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
      if (current == null) throw Exception('Please log in');

      await userService.updateCurrentUser(
        current.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        ),
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated 💕'), backgroundColor: VesperColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
            Text('Edit Profile', style: context.textStyles.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _save,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPrefsSheet extends StatefulWidget {
  const _NotificationPrefsSheet();

  @override
  State<_NotificationPrefsSheet> createState() => _NotificationPrefsSheetState();
}

class _NotificationPrefsSheetState extends State<_NotificationPrefsSheet> {
  late bool growthDateReminders;
  late bool appreciationPrompts;
  late bool peaceLilyNotifs;
  late bool pairingNotifs;
  late bool weeklyDigest;
  late bool streakCelebration;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserService>().user;
    growthDateReminders = user?.growthDateRemindersEnabled ?? true;
    appreciationPrompts = user?.appreciationPromptsEnabled ?? true;
    peaceLilyNotifs = user?.peaceLilyNotificationsEnabled ?? true;
    pairingNotifs = user?.pairingNotificationsEnabled ?? true;
    weeklyDigest = user?.weeklyDigestEnabled ?? false;
    streakCelebration = user?.streakCelebrationEnabled ?? true;
  }

  Future<void> _save() async {
    try {
      final userService = context.read<UserService>();
      final current = userService.user;
      if (current == null) throw Exception('Please log in');

      await userService.updateCurrentUser(
        current.copyWith(
          growthDateRemindersEnabled: growthDateReminders,
          appreciationPromptsEnabled: appreciationPrompts,
          peaceLilyNotificationsEnabled: peaceLilyNotifs,
          pairingNotificationsEnabled: pairingNotifs,
          weeklyDigestEnabled: weeklyDigest,
          streakCelebrationEnabled: streakCelebration,
        ),
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences saved'), backgroundColor: VesperColors.success),
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
            Text('Notification Preferences', style: context.textStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Text('Choose which notifications you\'d like to receive', style: context.textStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            _NotificationToggle(
              title: 'Growth Date Reminders',
              subtitle: '10 days before, 3 days before, and day of',
              value: growthDateReminders,
              onChanged: (v) => setState(() => growthDateReminders = v),
            ),
            _NotificationToggle(
              title: 'Appreciation Prompts',
              subtitle: 'Weekly reminders to share gratitude',
              value: appreciationPrompts,
              onChanged: (v) => setState(() => appreciationPrompts = v),
            ),
            _NotificationToggle(
              title: 'Peace Lily Received',
              subtitle: 'Instant notification when partner signals',
              value: peaceLilyNotifs,
              onChanged: (v) => setState(() => peaceLilyNotifs = v),
            ),
            _NotificationToggle(
              title: 'Pairing Notifications',
              subtitle: 'When partner accepts pairing request',
              value: pairingNotifs,
              onChanged: (v) => setState(() => pairingNotifs = v),
            ),
            _NotificationToggle(
              title: 'Weekly Digest',
              subtitle: 'Summary of partner activity',
              value: weeklyDigest,
              onChanged: (v) => setState(() => weeklyDigest = v),
            ),
            _NotificationToggle(
              title: 'Streak Celebration',
              subtitle: 'When both complete appreciation same week',
              value: streakCelebration,
              onChanged: (v) => setState(() => streakCelebration = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('Save Preferences')),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
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
