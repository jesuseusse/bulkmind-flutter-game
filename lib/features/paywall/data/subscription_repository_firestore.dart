import 'package:bulkmind/features/paywall/domain/subscription_models.dart';
import 'package:bulkmind/features/paywall/domain/subscription_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSubscriptionRepository implements SubscriptionRepository {
  final FirebaseFirestore _db;
  FirestoreSubscriptionRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productsCol =>
      _db.collection('products');

  CollectionReference<Map<String, dynamic>> get _discountCodesCol =>
      _db.collection('discountCodes');

  static SubscriptionPlan _planFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SubscriptionPlan(
      id: doc.id,
      priceCents: (d['priceCents'] as num).toInt(),
      currency: (d['currency'] as String).toUpperCase(),
      durationDays: (d['durationDays'] as num).toInt(),
      active: d['active'] == true,
    );
  }

  static DiscountCode _discountFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    DateTime? expiresAt;
    final raw = d['expiresAt'];
    if (raw is Timestamp) expiresAt = raw.toDate();
    if (raw is String) expiresAt = DateTime.tryParse(raw);
    final apps = (d['applicableProductIds'] as List?)?.whereType<String>().toList() ?? const <String>[];
    return DiscountCode(
      code: (d['code'] as String? ?? doc.id).toString(),
      percentOff: d['percentOff'] is num ? (d['percentOff'] as num).toInt() : null,
      amountOffCents: d['amountOffCents'] is num ? (d['amountOffCents'] as num).toInt() : null,
      expiresAt: expiresAt,
      maxRedemptions: d['maxRedemptions'] is num ? (d['maxRedemptions'] as num).toInt() : null,
      redeemedCount: d['redeemedCount'] is num ? (d['redeemedCount'] as num).toInt() : 0,
      active: d['active'] == true,
      applicableProductIds: apps,
    );
  }

  @override
  Future<SubscriptionPlan> getPlan(String id) async {
    final doc = await _productsCol.doc(id).get();
    if (!doc.exists) throw StateError('Product $id not found');
    return _planFromDoc(doc);
  }

  @override
  Future<SubscriptionPlan> getAnnualPlan() => getPlan('annual');

  @override
  Future<DiscountCode?> getDiscountCode(String code) async {
    final id = code.trim().toUpperCase();
    final doc = await _discountCodesCol.doc(id).get();
    if (!doc.exists) return null;
    return _discountFromDoc(doc);
  }

  @override
  Future<PriceQuote> quote({required String planId, String? discountCode}) async {
    final plan = await getPlan(planId);
    final currency = plan.currency;
    int discounted = plan.priceCents;
    String? usedCode;

    if (discountCode != null && discountCode.trim().isNotEmpty) {
      final dc = await getDiscountCode(discountCode);
      if (dc != null && _isDiscountValid(dc, forProductId: planId)) {
        usedCode = dc.code;
        discounted = _applyDiscount(plan.priceCents, dc);
      }
    }

    return PriceQuote(
      planId: plan.id,
      originalPriceCents: plan.priceCents,
      discountedPriceCents: discounted,
      currency: currency,
      discountCodeUsed: usedCode,
    );
  }

  bool _isDiscountValid(DiscountCode dc, {required String forProductId}) {
    if (!dc.active) return false;
    if (dc.expiresAt != null && !dc.expiresAt!.isAfter(DateTime.now())) return false;
    if (dc.maxRedemptions != null && dc.redeemedCount >= dc.maxRedemptions!) return false;
    if (dc.applicableProductIds.isNotEmpty && !dc.applicableProductIds.contains(forProductId)) return false;
    if ((dc.percentOff == null || dc.percentOff == 0) && (dc.amountOffCents == null || dc.amountOffCents == 0)) return false;
    return true;
  }

  int _applyDiscount(int priceCents, DiscountCode dc) {
    int result = priceCents;
    if (dc.amountOffCents != null && dc.amountOffCents! > 0) {
      result = priceCents - dc.amountOffCents!;
    } else if (dc.percentOff != null && dc.percentOff! > 0) {
      result = (priceCents * (100 - dc.percentOff!) / 100).round();
    }
    if (result < 0) result = 0;
    return result;
  }
}
