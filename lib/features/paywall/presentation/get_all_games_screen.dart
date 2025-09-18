import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:bulkmind/features/paywall/data/subscription_repository_firestore.dart';
import 'package:bulkmind/features/paywall/domain/subscription_models.dart';
import 'package:bulkmind/features/user/data/user_repository_firestore.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class _PayResult {
  final bool success;
  final String message;

  const _PayResult({required this.success, required this.message});
}

class GetAllGamesScreen extends StatefulWidget {
  const GetAllGamesScreen({super.key});

  static const routeName = "/get-all-games";

  @override
  State<GetAllGamesScreen> createState() => _GetAllGamesScreenState();
}

class _GetAllGamesScreenState extends State<GetAllGamesScreen> {
  final _discountController = TextEditingController();
  final _repo = FirestoreSubscriptionRepository();
  final _userRepo = FirestoreUserRepository();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance;

  SubscriptionPlan? _plan;
  PriceQuote? _quote;
  bool _loadingPlan = true;
  bool _applying = false;
  bool _purchasing = false;
  String? _status;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    try {
      setState(() {
        _loadingPlan = true;
        _status = null;
      });
      final plan = await _repo.getAnnualPlan();
      final quote = await _repo.quote(planId: plan.id);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _quote = quote;
        _loadingPlan = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPlan = false;
        _status = l10n.failedToLoadPrice;
      });
    }
  }

  Future<void> _applyCode() async {
    if (_plan == null) return;
    final code = _discountController.text.trim();
    setState(() {
      _applying = true;
      _status = null;
    });
    try {
      final quote = await _repo.quote(
        planId: _plan!.id,
        discountCode: code.isEmpty ? null : code,
      );
      if (!mounted) return;
      setState(() {
        _quote = quote;
        _applying = false;
        if (code.isEmpty) {
          _status = null;
        } else if (quote.discountCodeUsed != null) {
          _status = l10n.discountApplied;
        } else {
          _status = l10n.invalidOrExpiredCode;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _applying = false;
        _status = l10n.couldNotApplyCode;
      });
    }
  }

  Future<void> _onPayPressed() async {
    if (_plan == null) return;
    final quote = _quote ?? await _repo.quote(planId: _plan!.id);

    setState(() {
      _purchasing = true;
      _status = null;
    });

    late _PayResult result;
    try {
      if (quote.discountedPriceCents > 0) {
        result = await _startPaidPurchaseFlow(
          planId: quote.planId,
          priceCents: quote.discountedPriceCents,
          discountCode: quote.discountCodeUsed,
        );
      } else {
        await _handleComplimentaryRedemption(
          planId: quote.planId,
          discountCode: quote.discountCodeUsed,
        );
        result = _PayResult(
          success: true,
          message: l10n.complimentaryAccessGranted,
        );
      }
    } on StateError catch (_) {
      result = _PayResult(
        success: false,
        message: l10n.mustBeLoggedInToPurchase,
      );
    } catch (_) {
      result = _PayResult(
        success: false,
        message: l10n.purchaseFailed,
      );
    }

    if (!mounted) return;
    setState(() {
      _purchasing = false;
      _status = result.message;
    });

    if (result.success && mounted) {
      context.go('/');
    }
  }

  Future<_PayResult> _startPaidPurchaseFlow({
    required String planId,
    required int priceCents,
    String? discountCode,
  }) async {
    debugPrint(
      'Starting paid purchase for $planId at $priceCents cents (code: ${discountCode ?? '-'})',
    );
    if (kIsWeb) {
      return _PayResult(
        success: false,
        message: l10n.purchaseNotAvailableOnPlatform,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _PayResult(
          success: true,
          message: l10n.launchingGooglePlayPurchase,
        );
      case TargetPlatform.iOS:
        return _PayResult(
          success: true,
          message: l10n.launchingAppStorePurchase,
        );
      default:
        return _PayResult(
          success: false,
          message: l10n.purchaseNotAvailableOnPlatform,
        );
    }
  }

  Future<void> _handleComplimentaryRedemption({
    required String planId,
    String? discountCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be logged in to redeem discount');
    }

    if (discountCode != null && discountCode.isNotEmpty) {
      await _repo.incrementDiscountCodeRedemption(discountCode);
    }

    await _userRepo.updateSubscriptionDetails(
      user.uid,
      subscriptionMethod: _resolveSubscriptionMethod(),
      subscriptionExpiresAt: DateTime.now().add(
        Duration(days: _plan!.durationDays),
      ),
      subscriptionPlan: planId,
      discountCode: discountCode ?? '',
    );
  }

  String _resolveSubscriptionMethod() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getAllGamesTitle), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            // 1) Show price of annual subscription (localized formatting)
            _loadingPlan
                ? const Center(child: CircularProgressIndicator())
                : _plan == null
                ? Text(l10n.priceUnavailable)
                : Builder(
                    builder: (context) {
                      final currencyFmt = NumberFormat.simpleCurrency(
                        name: _plan!.currency,
                        locale: Localizations.localeOf(context).toLanguageTag(),
                      );
                      final priceText = currencyFmt.format(
                        _plan!.priceCents / 100,
                      );
                      return Text(
                        l10n.annualSubscriptionPrice(priceText),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            // 2) Discount code input and Apply button
            TextField(
              controller: _discountController,
              decoration: InputDecoration(
                labelText: l10n.discountCodeLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _applying ? null : _applyCode,
                child: _applying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.apply),
              ),
            ),
            const SizedBox(height: 16),
            // 3) Show final price with discount if any
            if (_quote != null && _plan != null) ...[
              Builder(
                builder: (context) {
                  final currencyFmt = NumberFormat.simpleCurrency(
                    name: _plan!.currency,
                    locale: Localizations.localeOf(context).toLanguageTag(),
                  );
                  final orig = currencyFmt.format(
                    _quote!.originalPriceCents / 100,
                  );
                  final finalP = currencyFmt.format(
                    _quote!.discountedPriceCents / 100,
                  );
                  final applied = _quote!.discountCodeUsed;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applied == null
                            ? l10n.finalPrice(finalP)
                            : l10n.finalPriceWithOriginal(finalP, orig),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (applied != null)
                        Text(
                          l10n.appliedCode(applied),
                          style: const TextStyle(fontSize: 13),
                        ),
                    ],
                  );
                },
              ),
            ],
            const Spacer(),
            if (_status != null) ...[
              Text(_status!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _purchasing || _loadingPlan || _plan == null
                    ? null
                    : _onPayPressed,
                child: _purchasing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.payNow),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () => context.go('/'),
              child: Text(l10n.goToHome),
            ),
          ],
        ),
      ),
    );
  }
}
