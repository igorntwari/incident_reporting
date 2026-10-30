import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_widgets.dart';

/// Blocks the app until the ALU inbox is confirmed. Polls quietly so the
/// user lands in the app as soon as they click the link in their email.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const _pollInterval = Duration(seconds: 5);
  Timer? _timer;

  AuthController get _controller => ref.read(authControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Silent background check: goes straight to the repository so the
    // buttons don't flash a spinner every few seconds. Once verified, the
    // refreshed ID token makes the router redirect into the app.
    final repo = ref.read(authRepositoryProvider);
    _timer = Timer.periodic(
      _pollInterval,
      (_) => repo.refreshEmailVerified().catchError((Object _) => false),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkNow() async {
    final verified = await _controller.checkEmailVerified();
    if (!verified && mounted) {
      context.showSnack('Not verified yet. Check your inbox and spam folder.');
    }
  }

  Future<void> _resend() async {
    if (await _controller.resendVerificationEmail() && mounted) {
      context.showSnack('Verification email sent.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listenForErrors(authControllerProvider, context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final email = ref.watch(authStateProvider).value?.email ?? 'your email';

    return AuthScaffold(
      icon: Icons.mark_email_unread_outlined,
      title: 'Verify your email',
      subtitle: 'We sent a verification link to $email. '
          'Open it to activate your account.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          PrimaryButton(
            label: "I've verified my email",
            isLoading: isLoading,
            onPressed: _checkNow,
          ),
          OutlinedButton(
            onPressed: isLoading ? null : _resend,
            child: const Text('Resend email'),
          ),
          TextButton(
            onPressed: _controller.signOut,
            child: Text('Use a different account',
                style: AppTextStyles.bodySecondary),
          ),
        ],
      ),
    );
  }
}
