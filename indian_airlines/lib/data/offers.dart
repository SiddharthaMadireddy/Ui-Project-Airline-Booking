import '../models/offer.dart';

/// Seeded repository of 12 original offers for Indian Airlines
class OffersData {
  static const List<Offer> offers = [
    // Bank Offers
    Offer(
      code: 'UPIPAY',
      title: 'UPI Instant Cashback',
      description: 'Get flat ₹250 instant discount on all UPI payments (GPay, PhonePe, Paytm).',
      category: 'Bank offers',
      flatDiscount: 250.0,
      minBookingAmount: 2500.0,
      badge: 'UPI EXCLUSIVE',
      expiry: 'Valid till 31 Dec 2026',
    ),
    Offer(
      code: 'HDFCFLY',
      title: 'HDFC Bank Cards 10% Off',
      description: 'Enjoy 10% discount up to ₹1,500 on HDFC Bank Credit & Debit Cards.',
      category: 'Bank offers',
      discountPercent: 10.0,
      minBookingAmount: 4000.0,
      badge: 'BANK OFFER',
      expiry: 'Valid till 30 Nov 2026',
    ),
    Offer(
      code: 'ICICISKY',
      title: 'ICICI Net Banking ₹600 Off',
      description: 'Flat ₹600 off on domestic & international flights paid via ICICI Net Banking.',
      category: 'Bank offers',
      flatDiscount: 600.0,
      minBookingAmount: 5000.0,
      badge: 'NET BANKING',
      expiry: 'Valid till 15 Dec 2026',
    ),

    // Discount Codes
    Offer(
      code: 'FIRST5',
      title: 'Welcome First Flight',
      description: 'New to Indian Airlines? Enjoy 5% off on your inaugural journey with us.',
      category: 'Discount codes',
      discountPercent: 5.0,
      minBookingAmount: 2000.0,
      badge: 'NEW USER',
      expiry: 'Valid on first booking',
    ),
    Offer(
      code: 'EARLYBIRD',
      title: 'Early Bird Advantage',
      description: 'Plan ahead and save 7% on flight bookings made 30+ days before departure.',
      category: 'Discount codes',
      discountPercent: 7.0,
      minBookingAmount: 3500.0,
      badge: 'PLAN AHEAD',
      expiry: 'Ongoing',
    ),
    Offer(
      code: 'SKYFLY',
      title: 'Mega Flat ₹400 Off',
      description: 'Instant discount of ₹400 across all domestic routes in India.',
      category: 'Discount codes',
      flatDiscount: 400.0,
      minBookingAmount: 3000.0,
      badge: 'POPULAR',
      expiry: 'Valid till 31 Dec 2026',
    ),

    // Limited-time
    Offer(
      code: 'SKYFAMILY',
      title: 'Family & Friends Saver',
      description: 'Book for 3 or more passengers and get 8% instant off on total base fare.',
      category: 'Limited-time',
      discountPercent: 8.0,
      minBookingAmount: 6000.0,
      badge: 'FAMILY SPECIAL',
      expiry: 'Ends this Sunday',
    ),
    Offer(
      code: 'FLYMONSOON',
      title: 'Seasonal Getaway Deal',
      description: 'Flat ₹750 off on flights to Goa, Kochi, Thiruvananthapuram, and Srinagar.',
      category: 'Limited-time',
      flatDiscount: 750.0,
      minBookingAmount: 4500.0,
      badge: 'LIMITED TIME',
      expiry: 'Ends in 4 days',
    ),
    Offer(
      code: 'WEEKENDGET',
      title: 'Weekend Escape Promo',
      description: 'Fly out Friday or Saturday and get flat ₹500 off on return flight bookings.',
      category: 'Limited-time',
      flatDiscount: 500.0,
      minBookingAmount: 4000.0,
      badge: 'WEEKEND SPECIAL',
      expiry: 'Valid on weekend flights',
    ),

    // Special Fares
    Offer(
      code: 'STUDENT10',
      title: 'Student Concession',
      description: '10% student discount plus 10 kg extra baggage allowance with valid college ID.',
      category: 'Special fares',
      discountPercent: 10.0,
      minBookingAmount: 2500.0,
      badge: 'STUDENT SPECIAL',
      expiry: 'Year-round concession',
    ),
    Offer(
      code: 'SENIOR8',
      title: 'Senior Citizen Privilege',
      description: '8% discount for Indian citizens aged 60 and above with priority check-in.',
      category: 'Special fares',
      discountPercent: 8.0,
      minBookingAmount: 2500.0,
      badge: 'SENIOR CITIZEN',
      expiry: 'Year-round concession',
    ),
    Offer(
      code: 'DEFENCE12',
      title: 'Armed Forces Honour',
      description: '12% special fare concession for Indian Armed Forces personnel and veterans.',
      category: 'Special fares',
      discountPercent: 12.0,
      minBookingAmount: 2000.0,
      badge: 'DEFENCE PRIVILEGE',
      expiry: 'Year-round concession',
    ),
  ];

  static Offer? findByCode(String code) {
    try {
      return offers.firstWhere(
        (o) => o.code.toUpperCase() == code.trim().toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
