import '../models/booking.dart';
import '../models/fare.dart';
import '../models/flight.dart';
import '../models/offer.dart';
import '../models/passenger.dart';

/// Business logic service for pricing, taxes, surcharges and add-on costs
class PricingService {
  /// Calculate comprehensive pricing breakdown
  static PricingBreakdown calculate({
    required Flight flight,
    Flight? returnFlight,
    required FareOption fareOption,
    required List<Passenger> passengers,
    String fareType = 'Regular',
    Offer? appliedOffer,
    bool hasInsurance = false,
    bool hasPriorityBoarding = false,
    int pointsToRedeem = 0,
  }) {
    final bool isInternational =
        !flight.origin.isDomestic || !flight.destination.isDomestic;

    // 1. Passenger Multipliers
    // Adult: 1.0, Child (2-11): 0.75, Infant (<2): 0.10
    double passengerWeightTotal = 0.0;
    for (final p in passengers) {
      if (p.type == 'Child') {
        passengerWeightTotal += 0.75;
      } else if (p.type == 'Infant') {
        passengerWeightTotal += 0.10;
      } else {
        passengerWeightTotal += 1.0;
      }
    }

    // Single leg base fare
    double baseFareOneWay = fareOption.price * passengerWeightTotal;

    // Return leg base fare (if round trip)
    double returnBaseFare = 0.0;
    if (returnFlight != null) {
      final returnFarePrice = returnFlight.fares.isNotEmpty
          ? returnFlight.fares.first.price
          : returnFlight.basePrice;
      returnBaseFare = returnFarePrice * passengerWeightTotal;
    }

    double totalBaseFare = baseFareOneWay + returnBaseFare;

    // 2. Special Fare Concessions on Base Fare
    if (fareType == 'Student') {
      totalBaseFare *= 0.90; // 10% student concession
    } else if (fareType == 'Senior Citizen') {
      totalBaseFare *= 0.92; // 8% senior citizen concession
    } else if (fareType == 'Armed Forces') {
      totalBaseFare *= 0.88; // 12% armed forces concession
    }

    // 3. Taxes & Statutory Surcharges
    // GST: 5% for Economy, 12% for Business
    final double gstRate = fareOption.type == FareFamilyType.business
        ? 0.12
        : 0.05;
    final double gst = totalBaseFare * gstRate;

    // User Development Fee (UDF): ₹350 per adult/child domestic, ₹950 intl
    final int taxablePaxCount = passengers
        .where((p) => p.type != 'Infant')
        .length;
    final double udfPerPax = isInternational ? 950.0 : 350.0;
    final double udf =
        udfPerPax * taxablePaxCount * (returnFlight != null ? 2 : 1);

    final double taxesAndFees = gst + udf;

    // Fuel Surcharge (YQ)
    final double fuelSurchargePerPax = isInternational ? 1500.0 : 450.0;
    final double fuelSurcharge =
        fuelSurchargePerPax * taxablePaxCount * (returnFlight != null ? 2 : 1);

    // Convenience fee
    const double convenienceFee = 350.0;

    // 4. Add-on costs
    // Seat selection fee
    double seatSelectionTotal = 0.0;
    for (final p in passengers) {
      if (p.seatNumber != null && p.seatNumber!.isNotEmpty) {
        if (fareOption.type == FareFamilyType.business) {
          // Free in business
        } else {
          final row =
              int.tryParse(p.seatNumber!.replaceAll(RegExp(r'[^0-9]'), '')) ??
              10;
          if (row <= 6) {
            seatSelectionTotal += 600.0; // Extra legroom
          } else {
            final col = p.seatNumber!.replaceAll(RegExp(r'[0-9]'), '');
            if (col == 'B' || col == 'E') {
              seatSelectionTotal += 150.0; // Middle seat
            } else {
              seatSelectionTotal += 250.0; // Window or Aisle
            }
          }
        }
      }
    }

    // Meals fee
    double mealsTotal = 0.0;
    for (final p in passengers) {
      if (p.mealPreference != null &&
          p.mealPreference!.isNotEmpty &&
          p.mealPreference != 'None') {
        if (fareOption.type == FareFamilyType.business ||
            fareOption.type == FareFamilyType.flex) {
          // Complimentary in Flex and Business
        } else {
          mealsTotal += 350.0;
        }
      }
    }

    // Extra Baggage fee (₹500 per 5kg)
    double baggageTotal = 0.0;
    for (final p in passengers) {
      if (p.extraBaggageKg > 0) {
        baggageTotal += (p.extraBaggageKg / 5.0) * 500.0;
      }
    }

    // Travel Insurance (₹299 per passenger)
    final double insuranceTotal = hasInsurance
        ? (299.0 * passengers.length)
        : 0.0;

    // Priority Boarding (₹399 per passenger, free in Business)
    final double priorityBoardingTotal =
        (hasPriorityBoarding && fareOption.type != FareFamilyType.business)
        ? (399.0 * passengers.length)
        : 0.0;

    // 5. Promo code discount
    double promoDiscount = 0.0;
    if (appliedOffer != null) {
      promoDiscount = appliedOffer.calculateDiscount(totalBaseFare);
    }

    // 6. Skyward loyalty points redemption (1 point = ₹0.50 discount, up to 50% of base fare)
    double pointsDiscount = 0.0;
    if (pointsToRedeem > 0) {
      final maxAllowedDiscount = totalBaseFare * 0.50;
      pointsDiscount = (pointsToRedeem * 0.50).clamp(0.0, maxAllowedDiscount);
    }

    // 7. Grand total
    final double subtotal =
        totalBaseFare +
        taxesAndFees +
        fuelSurcharge +
        convenienceFee +
        seatSelectionTotal +
        mealsTotal +
        baggageTotal +
        insuranceTotal +
        priorityBoardingTotal;

    final double grandTotal = (subtotal - promoDiscount - pointsDiscount).clamp(
      0.0,
      double.infinity,
    );

    return PricingBreakdown(
      baseFare: totalBaseFare,
      taxesAndFees: taxesAndFees,
      fuelSurcharge: fuelSurcharge,
      convenienceFee: convenienceFee,
      seatSelectionTotal: seatSelectionTotal,
      mealsTotal: mealsTotal,
      baggageTotal: baggageTotal,
      insuranceTotal: insuranceTotal,
      priorityBoardingTotal: priorityBoardingTotal,
      promoDiscount: promoDiscount,
      pointsDiscount: pointsDiscount,
      grandTotal: grandTotal,
    );
  }
}
