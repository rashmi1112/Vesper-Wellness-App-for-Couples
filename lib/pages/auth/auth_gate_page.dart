import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:vesper/pages/auth/signup_flow_page.dart';
import 'package:vesper/services/user_service.dart';
import 'package:vesper/auth/supabase_auth_manager.dart';
import 'package:vesper/theme.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _isLoggingIn = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoggingIn = true);
    try {
      final authManager = context.read<SupabaseAuthManager>();
      final userId = await authManager.signInWithEmail(
        context,
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );
      
      if (userId != null && mounted) {
        context.go('/');
      }
    } catch (e) {
      debugPrint('Login failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  Future<void> _unlockWithBiometrics() async {
    if (kIsWeb) return;
    final userService = context.read<UserService>();
    try {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      if (!canCheck) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics not available on this device.')));
        return;
      }
      final ok = await auth.authenticate(
        localizedReason: 'Unlock Vesper',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (ok) {
        await userService.unlockWithBiometrics();
        if (mounted) context.go('/');
      }
    } catch (e) {
      debugPrint('Biometric unlock failed: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not unlock. Please try again.')));
    }
  }

  void _showBackendRequired(String providerName) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connect a backend to use $providerName', style: context.textStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Google/Apple sign-in needs Firebase or Supabase. In Dreamflow, open the Firebase (or Supabase) panel and complete setup—then I can wire it in.',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.pop(), child: const Text('Got it'))),
            ],
          ),
        );
      },
    );
  }

  void _forgotPassword() {
    final emailController = TextEditingController(text: _loginEmailController.text);
    
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl + MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reset password', style: context.textStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter your email address and we\'ll send you a password reset link.',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(modalContext).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your email')),
                          );
                          return;
                        }
                        Navigator.of(modalContext).pop();
                        await context.read<SupabaseAuthManager>().resetPassword(
                          email: email,
                          context: context,
                        );
                      },
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();

    if (!userService.isInitialized || userService.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bg = Theme.of(context).colorScheme.primary;
    final onBg = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bg,
              bg.withValues(alpha: 0.92),
              VesperColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Text('Vesper', textAlign: TextAlign.center, style: context.textStyles.displayMedium?.copyWith(color: onBg)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Grow Together. Resolve Better. Appreciate Always.',
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodyLarge?.copyWith(color: onBg.withValues(alpha: 0.88)),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (userService.isBiometricGateRequired && !kIsWeb) ...[
                      ElevatedButton.icon(
                        onPressed: _unlockWithBiometrics,
                        icon: const Icon(Icons.fingerprint, color: Colors.white),
                        label: const Text('Unlock with Face ID / Fingerprint'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _AuthPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Log in', style: context.textStyles.titleLarge),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.username, AutofillHints.email],
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _loginPasswordController,
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: _forgotPassword, child: const Text('Forgot password?')),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton(
                            onPressed: _isLoggingIn ? null : _login,
                            child: _isLoggingIn
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Log In'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                child: Text('or', style: context.textStyles.labelMedium),
                              ),
                              Expanded(child: Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5))),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () => _showBackendRequired('Google Sign-In'),
                            icon: const Icon(Icons.g_mobiledata, color: VesperColors.primary),
                            label: const Text('Continue with Google'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: () => _showBackendRequired('Apple Sign-In'),
                            icon: const Icon(Icons.apple, color: VesperColors.primary),
                            label: const Text('Continue with Apple'),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              foregroundColor: VesperColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                            ),
                            onPressed: () => context.push(SignupFlowPage.routePath),
                            child: const Text('Create Account'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'By continuing, you agree to Vesper\'s Terms and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: context.textStyles.labelSmall?.copyWith(color: onBg.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthPanel extends StatelessWidget {
  final Widget child;
  const _AuthPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }
}
