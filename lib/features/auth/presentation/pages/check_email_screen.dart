import 'dart:async';

import 'package:bulkmind/features/auth/data/firebase_auth_repository.dart';
import 'package:bulkmind/features/auth/domain/check_email_verification_status_usecase.dart';
import 'package:bulkmind/features/auth/domain/send_email_verification_usecase.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckEmailScreen extends StatefulWidget {
  const CheckEmailScreen({super.key});

  static const routeName = '/verify-email';

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  final _authRepository = FirebaseAuthRepository();
  late final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  late final CheckEmailVerificationStatusUseCase _checkEmailVerificationStatusUseCase;

  Timer? _pollingTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _sendEmailVerificationUseCase = SendEmailVerificationUseCase(_authRepository);
    _checkEmailVerificationStatusUseCase =
        CheckEmailVerificationStatusUseCase(_authRepository);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationEmail(showFeedback: false);
      _checkVerificationStatus();
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _checkVerificationStatus();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail({required bool showFeedback}) async {
    setState(() {
      _isSending = true;
    });

    final localizations = AppLocalizations.of(context)!;

    try {
      await _sendEmailVerificationUseCase.call();
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.verificationEmailSent)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.verificationEmailError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final isVerified = await _checkEmailVerificationStatusUseCase.call();
      if (!mounted) return;
      if (isVerified) {
        _pollingTimer?.cancel();
        if (context.mounted) {
          context.go('/');
        }
      }
    } catch (_) {
      // Swallow errors silently to avoid interrupting the UX.
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final emailForSubtitle = currentEmail.isNotEmpty
        ? currentEmail
        : localizations.email.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.checkEmailTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.mark_email_read_outlined,
              size: 88,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              localizations.checkEmailTitle,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.checkEmailSubtitle(emailForSubtitle),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending
                    ? null
                    : () => _sendVerificationEmail(showFeedback: true),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(localizations.resendVerificationEmail),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.checkEmailHelp,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
