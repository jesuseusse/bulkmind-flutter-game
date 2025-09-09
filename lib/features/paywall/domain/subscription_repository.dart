import 'package:bulkmind/features/paywall/domain/subscription_models.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionPlan> getPlan(String id);
  Future<SubscriptionPlan> getAnnualPlan() => getPlan('annual');

  Future<DiscountCode?> getDiscountCode(String code);

  /// Returns a quote for the plan; if [discountCode] is provided and valid,
  /// applies it to calculate the discounted price.
  Future<PriceQuote> quote({
    required String planId,
    String? discountCode,
  });
}

