import '../models/booking.dart';
import '../models/fare.dart';
import '../models/flight.dart';

class RefundCalculationResult {
  final double baseFareRefund;
  final double taxesRefund;
  final double addOnsRefund;
  final double cancellationFee;
  final double totalRefund;
  final String policyExplanation;

  const RefundCalculationResult({
    required this.baseFareRefund,
    required this.taxesRefund,
    required this.addOnsRefund,
    required this.cancellationFee,
    required this.totalRefund,
    required this.policyExplanation,
  });
}

class RescheduleResult {
  final double fareDifference;
  final double changeFee;
  final double totalPayable;

  const RescheduleResult({
    required this.fareDifference,
    required this.changeFee,
    required this.totalPayable,
  });
}

/// Service for calculating cancellations, refunds and rescheduling fare differences
class RefundService {
  static RefundCalculationResult calculateCancellationRefund(
    Booking booking, {
    DateTime? cancellationTime,
  }) {
    final now = cancellationTime ?? DateTime.now();
    final departure = booking.flight.departureTime;
    final int hoursUntilDeparture = departure.difference(now).inHours;

    final pricing = booking.pricing;
    final bool isFlex = booking.fareFamily.toLowerCase().contains('flex');
    final bool isBusiness =
        booking.fareFamily.toLowerCase().contains('business');

    double baseFareRefund = 0.0;
    double taxesRefund = pricing.taxesAndFees; // Statutory taxes are always refundable
    double addOnsRefund = pricing.seatSelectionTotal +
        pricing.mealsTotal +
        pricing.baggageTotal +
        pricing.priorityBoardingTotal;
    double cancellationFee = 0.0;
    String policyExplanation = '';

    if (hoursUntilDeparture > 24) {
      // Greater than 24 hours before departure
      final basePercent = isBusiness ? 0.90 : (isFlex ? 0.85 : 0.80);
      baseFareRefund = pricing.baseFare * basePercent;
      cancellationFee = isBusiness ? 500.0 : (isFlex ? 750.0 : 1500.0);
      policyExplanation =
          'Cancelled >24 hours prior to flight: ${(basePercent * 100).toInt()}% base fare refund plus full taxes, minus ₹${cancellationFee.toInt()} cancellation fee.';
    } else if (hoursUntilDeparture >= 2) {
      // Between 2h and 24h
      final basePercent = isBusiness ? 0.70 : (isFlex ? 0.60 : 0.50);
      baseFareRefund = pricing.baseFare * basePercent;
      addOnsRefund *= 0.50; // 50% refund on ancillary services
      cancellationFee = isBusiness ? 1000.0 : (isFlex ? 1500.0 : 2500.0);
      policyExplanation =
          'Cancelled between 2h and 24h: ${(basePercent * 100).toInt()}% base fare refund plus taxes, minus ₹${cancellationFee.toInt()} cancellation fee.';
    } else {
      // Less than 2 hours before flight (No show / Last minute)
      baseFareRefund = 0.0;
      addOnsRefund = 0.0;
      cancellationFee = 0.0;
      policyExplanation =
          'Cancelled <2 hours before departure (Last-minute): Base fare is non-refundable. Only statutory airport taxes are refunded.';
    }

    final double totalRefund =
        (baseFareRefund + taxesRefund + addOnsRefund - cancellationFee)
            .clamp(0.0, double.infinity);

    return RefundCalculationResult(
      baseFareRefund: baseFareRefund,
      taxesRefund: taxesRefund,
      addOnsRefund: addOnsRefund,
      cancellationFee: cancellationFee,
      totalRefund: totalRefund,
      policyExplanation: policyExplanation,
    );
  }

  static RescheduleResult calculateReschedule({
    required Booking currentBooking,
    required Flight newFlight,
    required FareOption newFare,
  }) {
    final double oldFareBase = currentBooking.pricing.baseFare;
    final double newFareBase = newFare.price * currentBooking.passengers.length;

    final double fareDifference =
        (newFareBase - oldFareBase).clamp(0.0, double.infinity);

    final bool isFlex = currentBooking.fareFamily.toLowerCase().contains('flex');
    final bool isBusiness =
        currentBooking.fareFamily.toLowerCase().contains('business');

    final double changeFee = (isFlex || isBusiness) ? 0.0 : 1500.0;

    return RescheduleResult(
      fareDifference: fareDifference,
      changeFee: changeFee,
      totalPayable: fareDifference + changeFee,
    );
  }
}
