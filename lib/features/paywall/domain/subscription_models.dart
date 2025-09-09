class SubscriptionPlan {
  final String id;
  final int priceCents; // store minor units to avoid float rounding
  final String currency; // e.g. 'USD'
  final int durationDays; // e.g. 365
  final bool active;

  const SubscriptionPlan({
    required this.id,
    required this.priceCents,
    required this.currency,
    required this.durationDays,
    required this.active,
  });
}

class DiscountCode {
  final String code; // uppercase identifier, also the doc id
  final int? percentOff; // 0-100
  final int? amountOffCents; // absolute discount in minor units
  final DateTime? expiresAt;
  final int? maxRedemptions;
  final int redeemedCount;
  final bool active;
  final List<String> applicableProductIds; // empty => all products

  const DiscountCode({
    required this.code,
    this.percentOff,
    this.amountOffCents,
    this.expiresAt,
    this.maxRedemptions,
    required this.redeemedCount,
    required this.active,
    required this.applicableProductIds,
  });
}

class PriceQuote {
  final String planId;
  final int originalPriceCents;
  final int discountedPriceCents;
  final String currency;
  final String? discountCodeUsed;

  const PriceQuote({
    required this.planId,
    required this.originalPriceCents,
    required this.discountedPriceCents,
    required this.currency,
    this.discountCodeUsed,
  });
}

