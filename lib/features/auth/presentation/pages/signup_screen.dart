import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bulkmind/features/auth/domain/signup_usecase.dart';
import 'package:bulkmind/features/auth/data/firebase_auth_repository.dart';
import 'package:bulkmind/features/auth/presentation/pages/check_email_screen.dart';
import 'package:bulkmind/features/user/data/user_repository_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// A StatefulWidget to handle form state and user interaction.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const routeName = "/sign-up";

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text controllers for form fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  DateTime _birthDate = DateTime(1970, 1, 1);

  // State variables.
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _passwordError;
  bool _privacyPolicyAccepted = false;
  bool _showPrivacyPolicyError = false;
  final Uri _privacyPolicyUri = Uri.parse(
    'https://jesuseusse.com/privacy-policy',
  );
  late final TapGestureRecognizer _privacyPolicyTapRecognizer;

  // Dependencies for the use case. In a real app, you would use a dependency injection
  // framework (like get_it) to provide these.
  final _authRepository = FirebaseAuthRepository();
  final _userRepository = FirestoreUserRepository();
  late final SignUpUseCase _signUpUseCase;

  @override
  void initState() {
    super.initState();
    _signUpUseCase = SignUpUseCase(_authRepository, _userRepository);
    _privacyPolicyTapRecognizer = TapGestureRecognizer()
      ..onTap = _openPrivacyPolicy;
  }

  String? _validatePassword(String password, AppLocalizations l10n) {
    if (password.length < 9) return l10n.passwordInvalid;
    final hasUpper = RegExp(r"[A-Z]").hasMatch(password);
    final hasLower = RegExp(r"[a-z]").hasMatch(password);
    final hasNumber = RegExp(r"\d").hasMatch(password);
    final hasSpecial = RegExp(r"[^A-Za-z0-9]").hasMatch(password);
    if (!hasUpper || !hasLower || !hasNumber || !hasSpecial) {
      return l10n.passwordInvalid;
    }
    return null;
  }

  // The helper method to calculate age is no longer needed here,
  // as the use case now accepts the DateTime object directly.

  Future<void> _signUp() async {
    final localizations = AppLocalizations.of(context)!;

    if (!_privacyPolicyAccepted) {
      setState(() {
        _showPrivacyPolicyError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.privacyPolicyRequired)),
      );
      return;
    }

    // Validate password strength first
    final pwdError = _validatePassword(
      _passwordController.text.trim(),
      localizations,
    );
    if (pwdError != null) {
      setState(() {
        _passwordError = pwdError;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(pwdError)));
      return;
    } else {
      if (_passwordError != null) {
        setState(() {
          _passwordError = null;
        });
      }
    }

    // Basic check before hitting the use case
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.passwordsDoNotMatch)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // The use case now directly accepts the birthday as a DateTime object.
      await _signUpUseCase.call(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        birthday: _birthDate,
      );
      if (mounted) {
        // Navigate to the email verification screen on success.
        context.go(CheckEmailScreen.routeName);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Unknown error.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _birthdayController.dispose();
    _privacyPolicyTapRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openPrivacyPolicy() async {
    await launchUrl(_privacyPolicyUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.signUp), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AutofillGroup(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Full Name Field.
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: localizations.fullName,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.name,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: 16),
                // Birthday Field (date picker).
                TextField(
                  controller: _birthdayController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: localizations.birthday,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  autofillHints: const [AutofillHints.birthday],
                  onTap: () async {
                    final now = DateTime.now();
                    final initial = _birthDate;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(1900),
                      lastDate: now,
                    );
                    if (picked != null) {
                      setState(() {
                        _birthDate = picked;
                        _birthdayController.text =
                            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Email Field.
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.email,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                ),
                const SizedBox(height: 16),
                // Password Field with visibility toggle.
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: localizations.password,
                    border: const OutlineInputBorder(),
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (value) {
                    final l10n = AppLocalizations.of(context)!;
                    setState(() {
                      _passwordError = _validatePassword(value, l10n);
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Confirm Password Field with visibility toggle.
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: localizations.confirmPassword,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_confirmPasswordVisible,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _privacyPolicyAccepted,
                      onChanged: (value) {
                        setState(() {
                          _privacyPolicyAccepted = value ?? false;
                          if (_privacyPolicyAccepted) {
                            _showPrivacyPolicyError = false;
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: localizations.privacyPolicyAgreementPrefix,
                            ),
                            TextSpan(
                              text: localizations.privacyPolicyLinkText,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: _privacyPolicyTapRecognizer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showPrivacyPolicyError && !_privacyPolicyAccepted)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.privacyPolicyRequired,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Sign-up Button.
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signUp,
                        child: Text(localizations.signUp),
                      ),
                const SizedBox(height: 16),
                // Sign-up with Google Button.
                // ElevatedButton(
                //   onPressed: () {
                //     // TODO: Implement Google sign-in logic here using the AuthRepository.
                //   },
                //   child: Text(localizations.loginWithGoogle),
                // ),
                const SizedBox(height: 16),
                // Navigate to sign-in page.
                TextButton(
                  onPressed: () => context.go('/sign-in'),
                  child: Text(localizations.signIn),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(localizations.continueWithOutSignIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
