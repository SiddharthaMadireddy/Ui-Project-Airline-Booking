/// Offer model for promo codes and discounts
class Offer {
  final String code;
  final String title;
  final String description;
  final String category; // Bank offers, Discount codes, Limited-time, Special fares
  final double discountPercent; // e.g. 10.0 for 10%
  final double flatDiscount; // e.g. 500 for ₹500 off
  final double minBookingAmount;
  final String badge;
  final String expiry;

  const Offer({
    required this.code,
    required this.title,
    required this.description,
    required this.category,
    this.discountPercent = 0.0,
    this.flatDiscount = 0.0,
    this.minBookingAmount = 0.0,
    required this.badge,
    required this.expiry,
  });

  /// Compute discount amount for a given base fare
  double calculateDiscount(double amount) {
    if (amount < minBookingAmount) return 0.0;
    if (discountPercent > 0) {
      final calculated = (amount * discountPercent) / 100.0;
      return calculated;
    }
    return flatDiscount;
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'description': description,
        'category': category,
        'discountPercent': discountPercent,
        'flatDiscount': flatDiscount,
        'minBookingAmount': minBookingAmount,
        'badge': badge,
        'expiry': expiry,
      };

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        code: json['code'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
        flatDiscount: (json['flatDiscount'] as num?)?.toDouble() ?? 0.0,
        minBookingAmount:
            (json['minBookingAmount'] as num?)?.toDouble() ?? 0.0,
        badge: json['badge'] as String? ?? 'OFFER',
        expiry: json['expiry'] as String? ?? 'Valid till 31 Dec 2026',
      );
}
