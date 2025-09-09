import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bulkmind/features/paywall/data/subscription_repository_firestore.dart';
import 'package:bulkmind/features/paywall/domain/subscription_models.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class GetAllGamesScreen extends StatefulWidget {
  const GetAllGamesScreen({super.key});

  static const routeName = "/get-all-games";

  @override
  State<GetAllGamesScreen> createState() => _GetAllGamesScreenState();
}

class _GetAllGamesScreenState extends State<GetAllGamesScreen> {
  final _discountController = TextEditingController();
  final _repo = FirestoreSubscriptionRepository();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

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

  Future<void> _purchase() async {
    setState(() {
      _purchasing = true;
      _status = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _purchasing = false;
      _status = l10n.purchaseFlowStub;
    });
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
                onPressed: _purchasing ? null : _purchase,
                child: _purchasing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.purchaseAnnualSubscription),
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
