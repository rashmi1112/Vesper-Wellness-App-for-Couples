import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vesper/models/user_model.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/services/notification_service.dart';
import 'package:vesper/auth/supabase_auth_manager.dart';
import 'package:vesper/theme.dart';

class SignupFlowPage extends StatefulWidget {
  static const routePath = '/sign-up';
  const SignupFlowPage({super.key});

  @override
  State<SignupFlowPage> createState() => _SignupFlowPageState();
}

class _SignupFlowPageState extends State<SignupFlowPage> with TickerProviderStateMixin {
  final _controller = PageController();
  int _step = 0;

  // Step 2
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _dob;
  String _genderOrientation = 'Prefer not to say';
  String? _photoBase64;

  // Step 3
  String _relationshipLength = 'Less than 1 year';
  String _relationshipFeeling = 'Good';
  final Set<String> _goals = {};
  DateTime? _anniversaryDate;

  // Step 4
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  bool _agreed = false;
  bool _isCreatingAccount = false;
  String? _createdUserId;

  // Step 5
  String _pairingMode = 'email';
  final _pairingQuery = TextEditingController();
  UserModel? _pairingMatch;
  bool _isSearching = false;
  bool _requestSent = false;

  @override
  void dispose() {
    _controller.dispose();
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _pairingQuery.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step == 0) {
      final ok = _validatePersonalDetails();
      if (!ok) return;
    }
    if (_step == 1) {
      if (_goals.isEmpty) {
        _snack('Select at least one reason.');
        return;
      }
    }
    if (_step == 2) {
      final ok = await _validateAndCreateAccount();
      if (!ok) return;
    }

    if (_step < 4) {
      await _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  Future<void> _back() async {
    if (_step > 0) {
      await _controller.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    } else {
      if (mounted) context.pop();
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  bool _validatePersonalDetails() {
    final name = _fullName.text.trim();
    final email = _email.text.trim();
    if (name.isEmpty) return _fail('Please enter your full name');
    if (email.isEmpty || !email.contains('@')) return _fail('Please enter a valid email');
    if (_phone.text.trim().isEmpty) return _fail('Please enter your phone number');
    if (_dob == null) return _fail('Please select your date of birth');

    final age = _yearsBetween(_dob!, DateTime.now());
    if (age < 18) return _fail('You must be 18 or older to use Togetherly');
    return true;
  }

  bool _fail(String message) {
    _snack(message);
    return false;
  }

  int _yearsBetween(DateTime a, DateTime b) {
    var years = b.year - a.year;
    if (b.month < a.month || (b.month == a.month && b.day < a.day)) years -= 1;
    return years;
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 720, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _photoBase64 = base64Encode(bytes));
    } catch (e) {
      debugPrint('Pick photo failed: $e');
      if (mounted) _snack('Could not pick photo.');
    }
  }

  PasswordStrength _passwordStrength(String input) {
    final v = input.trim();
    if (v.length < 8) return PasswordStrength.weak;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(v);
    final hasLower = RegExp(r'[a-z]').hasMatch(v);
    final hasDigit = RegExp(r'[0-9]').hasMatch(v);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(v);
    final score = [hasUpper, hasLower, hasDigit, hasSymbol].where((x) => x).length;
    if (score <= 1) return PasswordStrength.weak;
    if (score == 2) return PasswordStrength.ok;
    return PasswordStrength.strong;
  }

  Future<bool> _validateAndCreateAccount() async {
    final pw = _password.text;
    if (pw.isEmpty || pw.length < 8) return _fail('Password must be at least 8 characters');
    if (pw != _passwordConfirm.text) return _fail('Passwords do not match');
    if (!_agreed) return _fail('Please agree to the terms and privacy policy');

    final strength = _passwordStrength(pw);
    if (strength == PasswordStrength.weak) {
      return _fail('Choose a stronger password (add symbols, numbers, and mixed case).');
    }

    setState(() => _isCreatingAccount = true);
    try {
      final authManager = context.read<SupabaseAuthManager>();
      
      // Create auth account
      final userId = await authManager.createAccountWithEmail(
        context,
        _email.text.trim(),
        pw,
      );
      
      if (userId == null) {
        return false;
      }
      
      // Create user profile
      final user = UserModel(
        id: userId,
        name: _fullName.text.trim(),
        email: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
        dateOfBirth: _dob!,
        genderOrientation: _genderOrientation,
        relationshipLength: _relationshipLength,
        relationshipFeeling: _relationshipFeeling,
        togetherlyGoals: _goals.toList(),
        profilePhotoBase64: _photoBase64,
        anniversaryDate: _anniversaryDate,
      );
      
      await authManager.createUserProfile(user);
      
      setState(() => _createdUserId = userId);
      return true;
    } catch (e) {
      debugPrint('Create account failed: $e');
      _snack(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      if (mounted) setState(() => _isCreatingAccount = false);
    }
  }

  Future<void> _searchMatch() async {
    setState(() {
      _isSearching = true;
      _pairingMatch = null;
      _requestSent = false;
    });

    try {
      final service = context.read<UserService>();
      final query = _pairingQuery.text.trim();
      UserModel? match;
      if (_pairingMode == 'email') {
        match = await service.findUserByEmail(query);
      } else if (_pairingMode == 'phone') {
        match = await service.findUserByPhone(query);
      } else {
        match = await service.findUserById(query);
      }

      if (match == null) {
        _snack(_pairingMode == 'qr' ? 'No account found with that code' : 'No account found');
      }

      setState(() => _pairingMatch = match);
    } catch (e) {
      debugPrint('Search match failed: $e');
      _snack('Search failed, please try again');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _sendRequest() async {
    final match = _pairingMatch;
    if (match == null) return;

    try {
      await context.read<UserService>().sendLinkRequest(partnerUserId: match.id);
      setState(() => _requestSent = true);
    } catch (e) {
      debugPrint('Send link request failed: $e');
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create account', style: context.textStyles.titleLarge),
        leading: IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back, color: VesperColors.textPrimary)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
              child: _StepProgress(current: _step, total: 5),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _PersonalDetailsStep(
                    fullName: _fullName,
                    email: _email,
                    phone: _phone,
                    dob: _dob,
                    genderOrientation: _genderOrientation,
                    photoBase64: _photoBase64,
                    onPickDob: () async {
                      final now = DateTime.now();
                      final initial = _dob ?? DateTime(now.year - 24, now.month, now.day);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(now.year - 18, now.month, now.day),
                      );
                      if (picked != null) setState(() => _dob = picked);
                    },
                    onPickPhoto: _pickPhoto,
                    onGenderChanged: (v) => setState(() => _genderOrientation = v),
                  ),
                  _YourStoryStep(
                    relationshipLength: _relationshipLength,
                    relationshipFeeling: _relationshipFeeling,
                    goals: _goals,
                    anniversaryDate: _anniversaryDate,
                    onRelationshipLengthChanged: (v) => setState(() => _relationshipLength = v),
                    onFeelingChanged: (v) => setState(() => _relationshipFeeling = v),
                    onToggleGoal: (goal) => setState(() {
                      if (_goals.contains(goal)) {
                        _goals.remove(goal);
                      } else {
                        _goals.add(goal);
                      }
                      if (_goals.contains('All of the above')) {
                        _goals
                          ..clear()
                          ..addAll(const [
                            'Better communication',
                            'Working through conflict',
                            'Growing together',
                            'Appreciating each other more',
                            'All of the above',
                          ]);
                      }
                    }),
                    onPickAnniversary: () async {
                      final now = DateTime.now();
                      final initial = _anniversaryDate ?? DateTime(now.year - 1, now.month, now.day);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(1950),
                        lastDate: now,
                      );
                      if (picked != null) setState(() => _anniversaryDate = picked);
                    },
                  ),
                  _SetPasswordStep(
                    password: _password,
                    passwordConfirm: _passwordConfirm,
                    agreed: _agreed,
                    strength: _passwordStrength(_password.text),
                    isSubmitting: _isCreatingAccount,
                    onAgreedChanged: (v) => setState(() => _agreed = v),
                    onPasswordChanged: (_) => setState(() {}),
                  ),
                  _PartnerPairingStep(
                    createdUserId: _createdUserId,
                    pairingMode: _pairingMode,
                    queryController: _pairingQuery,
                    match: _pairingMatch,
                    isSearching: _isSearching,
                    requestSent: _requestSent,
                    onModeChanged: (m) => setState(() {
                      _pairingMode = m;
                      _pairingQuery.clear();
                      _pairingMatch = null;
                      _requestSent = false;
                    }),
                    onSearch: _searchMatch,
                    onSendRequest: _sendRequest,
                  ),
                  _SuccessStep(
                    onDone: () => context.go('/'),
                    accent: cs.secondary,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _step == 0 ? _back : () => _controller.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_step == 2 && _isCreatingAccount) ? null : (_step == 4 ? null : _next),
                      child: Text(_step == 3 ? 'Continue' : (_step == 4 ? 'Done' : 'Next')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PasswordStrength { weak, ok, strong }

class _StepProgress extends StatelessWidget {
  final int current;
  final int total;
  const _StepProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 6,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
            decoration: BoxDecoration(
              color: active ? cs.primary : cs.outline.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _PersonalDetailsStep extends StatelessWidget {
  final TextEditingController fullName;
  final TextEditingController email;
  final TextEditingController phone;
  final DateTime? dob;
  final String genderOrientation;
  final String? photoBase64;
  final VoidCallback onPickDob;
  final VoidCallback onPickPhoto;
  final ValueChanged<String> onGenderChanged;

  const _PersonalDetailsStep({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.genderOrientation,
    required this.photoBase64,
    required this.onPickDob,
    required this.onPickPhoto,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final genders = const ['Straight', 'Gay', 'Lesbian', 'Bisexual', 'Pansexual', 'Prefer not to say', 'Other'];

    ImageProvider? avatar;
    if (photoBase64 != null) {
      try {
        avatar = MemoryImage(base64Decode(photoBase64!));
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal details', style: context.textStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('A little context helps us personalize your experience.', style: context.textStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: cs.secondary.withValues(alpha: 0.5),
                  backgroundImage: avatar,
                  child: avatar == null ? const Icon(Icons.person, size: 44, color: VesperColors.primary) : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: onPickPhoto,
                  icon: const Icon(Icons.photo_camera_outlined, color: VesperColors.primary),
                  label: const Text('Upload profile photo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(controller: fullName, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number')),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: onPickDob,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date of Birth'),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dob == null ? 'Select date' : '${dob!.month}/${dob!.day}/${dob!.year}',
                      style: context.textStyles.bodyLarge?.copyWith(color: cs.onSurface),
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: VesperColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: genderOrientation,
            decoration: const InputDecoration(labelText: 'Gender / Orientation'),
            items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => onGenderChanged(v ?? genders.last),
          ),
        ],
      ),
    );
  }
}

class _YourStoryStep extends StatelessWidget {
  final String relationshipLength;
  final String relationshipFeeling;
  final Set<String> goals;
  final DateTime? anniversaryDate;
  final ValueChanged<String> onRelationshipLengthChanged;
  final ValueChanged<String> onFeelingChanged;
  final ValueChanged<String> onToggleGoal;
  final VoidCallback onPickAnniversary;

  const _YourStoryStep({
    required this.relationshipLength,
    required this.relationshipFeeling,
    required this.goals,
    required this.anniversaryDate,
    required this.onRelationshipLengthChanged,
    required this.onFeelingChanged,
    required this.onToggleGoal,
    required this.onPickAnniversary,
  });

  @override
  Widget build(BuildContext context) {
    final lengths = const ['Less than 1 year', '1 to 3 years', '3 to 5 years', '5 to 10 years', '10 plus years'];
    final feelings = const ['Great', 'Good', 'Could be better', 'Going through a rough patch', 'Not sure'];
    final reasons = const [
      'Better communication',
      'Working through conflict',
      'Growing together',
      'Appreciating each other more',
      'All of the above',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your story', style: context.textStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Tell us a little about you and your relationship.', style: context.textStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          DropdownButtonFormField<String>(
            value: relationshipLength,
            decoration: const InputDecoration(labelText: 'How long have you been in this relationship?'),
            items: lengths.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) => onRelationshipLengthChanged(v ?? lengths.first),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: onPickAnniversary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Anniversary Date (Optional)',
                hintText: 'When did you start dating?',
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      anniversaryDate == null 
                          ? 'Select date' 
                          : '${anniversaryDate!.month}/${anniversaryDate!.day}/${anniversaryDate!.year}',
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: anniversaryDate == null 
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: VesperColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('How are you feeling right now?', style: context.textStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: feelings.map((f) {
              final selected = relationshipFeeling == f;
              return ChoiceChip(
                label: Text(f),
                selected: selected,
                onSelected: (_) => onFeelingChanged(f),
                labelStyle: context.textStyles.labelMedium?.copyWith(color: selected ? Colors.white : VesperColors.textPrimary),
                selectedColor: VesperColors.primary,
                backgroundColor: VesperColors.accent.withValues(alpha: 0.35),
                showCheckmark: false,
                side: BorderSide(color: VesperColors.primary.withValues(alpha: selected ? 0 : 0.2)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('What brings you to Togetherly?', style: context.textStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: reasons.map((r) {
              final selected = goals.contains(r);
              return FilterChip(
                label: Text(r),
                selected: selected,
                onSelected: (_) => onToggleGoal(r),
                labelStyle: context.textStyles.labelMedium?.copyWith(color: selected ? Colors.white : VesperColors.textPrimary),
                selectedColor: VesperColors.primary,
                backgroundColor: VesperColors.accent.withValues(alpha: 0.35),
                showCheckmark: false,
                side: BorderSide(color: VesperColors.primary.withValues(alpha: selected ? 0 : 0.2)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SetPasswordStep extends StatefulWidget {
  final TextEditingController password;
  final TextEditingController passwordConfirm;
  final bool agreed;
  final PasswordStrength strength;
  final bool isSubmitting;
  final ValueChanged<bool> onAgreedChanged;
  final ValueChanged<String> onPasswordChanged;

  const _SetPasswordStep({
    required this.password,
    required this.passwordConfirm,
    required this.agreed,
    required this.strength,
    required this.isSubmitting,
    required this.onAgreedChanged,
    required this.onPasswordChanged,
  });

  @override
  State<_SetPasswordStep> createState() => _SetPasswordStepState();
}

class _SetPasswordStepState extends State<_SetPasswordStep> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, color, value) = switch (widget.strength) {
      PasswordStrength.weak => ('Weak', VesperColors.error, 0.33),
      PasswordStrength.ok => ('Okay', VesperColors.warning, 0.66),
      PasswordStrength.strong => ('Strong', VesperColors.success, 1.0),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set password', style: context.textStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Keep it memorable—and hard to guess.', style: context.textStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: widget.password,
            obscureText: _obscure,
            onChanged: widget.onPasswordChanged,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: cs.outline.withValues(alpha: 0.25),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(label, style: context.textStyles.labelMedium?.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: widget.passwordConfirm,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: widget.agreed, onChanged: widget.isSubmitting ? null : (v) => widget.onAgreedChanged(v ?? false)),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I agree to the Terms and Privacy Policy',
                    style: context.textStyles.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartnerPairingStep extends StatelessWidget {
  final String? createdUserId;
  final String pairingMode;
  final TextEditingController queryController;
  final UserModel? match;
  final bool isSearching;
  final bool requestSent;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onSearch;
  final VoidCallback onSendRequest;

  const _PartnerPairingStep({
    required this.createdUserId,
    required this.pairingMode,
    required this.queryController,
    required this.match,
    required this.isSearching,
    required this.requestSent,
    required this.onModeChanged,
    required this.onSearch,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final me = userService.currentUser;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Partner pairing', style: context.textStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your partner needs to create their own account first. Then you can link your profiles. (Poly-friendly: you can link more than one partner.)',
            style: context.textStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _PairingModeCard(
                  title: 'Search by email',
                  subtitle: 'Find them by email address',
                  icon: Icons.alternate_email,
                  selected: pairingMode == 'email',
                  onTap: () => onModeChanged('email'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PairingModeCard(
                  title: 'Search by phone',
                  subtitle: 'Find them by phone number',
                  icon: Icons.phone_iphone,
                  selected: pairingMode == 'phone',
                  onTap: () => onModeChanged('phone'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PairingModeCard(
            title: 'Scan / share a QR code',
            subtitle: 'Use a shareable code for now',
            icon: Icons.qr_code_2,
            selected: pairingMode == 'qr',
            onTap: () => onModeChanged('qr'),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (pairingMode == 'qr' && me != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  QrImageView(
                    data: me.id,
                    size: 92,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: VesperColors.primary),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: VesperColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your pairing code', style: context.textStyles.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(me.id, style: context.textStyles.labelMedium?.copyWith(color: VesperColors.textSecondary)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'QR scanning needs a backend + camera permissions; we can enable it next.',
                          style: context.textStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          TextField(
            controller: queryController,
            decoration: InputDecoration(
              labelText: switch (pairingMode) {
                'email' => 'Partner email',
                'phone' => 'Partner phone number',
                _ => 'Partner pairing code',
              },
              suffixIcon: IconButton(
                onPressed: isSearching ? null : onSearch,
                icon: const Icon(Icons.search, color: VesperColors.primary),
              ),
            ),
            keyboardType: pairingMode == 'phone'
                ? TextInputType.phone
                : (pairingMode == 'email' ? TextInputType.emailAddress : TextInputType.text),
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isSearching) const Center(child: CircularProgressIndicator()),
          if (!isSearching && match != null) ...[
            _PartnerPreviewCard(
              partner: match!,
              requestSent: requestSent,
              onSend: onSendRequest,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (me != null && me.incomingLinkRequests.isNotEmpty) ...[
            Text('Pending requests', style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ...me.incomingLinkRequests.map((id) => _IncomingRequestTile(userId: id)),
          ],
        ],
      ),
    );
  }
}

class _IncomingRequestTile extends StatelessWidget {
  final String userId;
  const _IncomingRequestTile({required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<UserService>();
    return FutureBuilder<UserModel?>(
      future: service.findUserById(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final other = snapshot.data;
        if (other == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: VesperColors.accent.withValues(alpha: 0.5),
                child: const Icon(Icons.person, size: 18, color: VesperColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(other.name, style: context.textStyles.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface))),
              const SizedBox(width: AppSpacing.md),
              TextButton(
                onPressed: () async {
                  try {
                    await service.acceptLinkRequest(
                      fromUserId: other.id,
                      notificationService: context.read<NotificationService>(),
                    );
                  } catch (e) {
                    debugPrint('Accept request failed: $e');
                  }
                },
                child: const Text('Accept'),
              ),
              TextButton(
                onPressed: () => service.declineLinkRequest(fromUserId: other.id),
                child: const Text('Decline'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PairingModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PairingModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.10) : cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: selected ? cs.primary : cs.outline.withValues(alpha: 0.25), width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? cs.primary : VesperColors.accent.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: selected ? Colors.white : VesperColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textStyles.titleMedium?.copyWith(color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: context.textStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerPreviewCard extends StatelessWidget {
  final UserModel partner;
  final bool requestSent;
  final VoidCallback onSend;

  const _PartnerPreviewCard({required this.partner, required this.requestSent, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    ImageProvider? avatar;
    if (partner.profilePhotoBase64 != null) {
      try {
        avatar = MemoryImage(base64Decode(partner.profilePhotoBase64!));
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: VesperColors.accent.withValues(alpha: 0.5),
            backgroundImage: avatar,
            child: avatar == null ? const Icon(Icons.person, color: VesperColors.primary) : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner.name, style: context.textStyles.titleLarge?.copyWith(color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(partner.email.isEmpty ? partner.phoneNumber : partner.email, style: context.textStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton(
            onPressed: requestSent ? null : onSend,
            child: Text(requestSent ? 'Request sent' : 'Send Link Request'),
          ),
        ],
      ),
    );
  }
}

class _SuccessStep extends StatefulWidget {
  final VoidCallback onDone;
  final Color accent;
  const _SuccessStep({required this.onDone, required this.accent});

  @override
  State<_SuccessStep> createState() => _SuccessStepState();
}

class _SuccessStepState extends State<_SuccessStep> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              return CustomPaint(
                painter: _HeartsPainter(progress: t, accent: widget.accent, surface: cs.surface),
              );
            },
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, size: 40, color: VesperColors.primary),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Welcome to Togetherly', style: context.textStyles.headlineLarge, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '“Every great relationship is built one honest conversation at a time.”',
                  style: context.textStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: widget.onDone, child: const Text('Let\'s get started'))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeartsPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final Color surface;

  _HeartsPainter({required this.progress, required this.accent, required this.surface});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final hearts = [
      (0.18, 0.30, 14.0),
      (0.82, 0.22, 18.0),
      (0.10, 0.76, 16.0),
      (0.88, 0.72, 12.0),
      (0.50, 0.14, 20.0),
    ];

    for (final (x, y, r) in hearts) {
      final dy = (progress * 2 - 1) * 22;
      final center = Offset(size.width * x, size.height * y + dy);
      paint.color = accent.withValues(alpha: 0.18);
      canvas.drawCircle(center, r * 1.6, paint);
      paint.color = VesperColors.primary.withValues(alpha: 0.08);
      canvas.drawCircle(center.translate(0, 6), r * 2.1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartsPainter oldDelegate) => oldDelegate.progress != progress;
}
