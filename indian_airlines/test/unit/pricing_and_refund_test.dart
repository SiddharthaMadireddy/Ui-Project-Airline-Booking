import 'package:flutter_test/flutter_test.dart';
import 'package:indian_airlines/data/airports.dart';
import 'package:indian_airlines/models/booking.dart';
import 'package:indian_airlines/models/fare.dart';
import 'package:indian_airlines/models/flight.dart';
import 'package:indian_airlines/models/offer.dart';
import 'package:indian_airlines/models/passenger.dart';
import 'package:indian_airlines/services/pricing_service.dart';
import 'package:indian_airlines/services/refund_service.dart';

void main() {
  group('PricingService Unit Tests', () {
    late Flight testFlight;
    late FareOption testFare;

    setUp(() {
      final origin = AirportData.findByCode('DEL')!;
      final dest = AirportData.findByCode('BOM')!;
      testFare = const FareOption(
        type: FareFamilyType.saver,
        name: 'Economy Saver',
        price: 5000.0,
        cabinBaggage: '7 kg',
        checkInBaggage: '15 kg',
        seatSelection: 'Chargeable',
        meal: 'Chargeable',
        cancellationFee: 1500.0,
        changeFee: 2000.0,
        refundRule: 'Saver rules',
        benefits: [],
      );

      testFlight = Flight(
        flightNumber: 'IA-204',
        origin: origin,
        destination: dest,
        departureTime: DateTime.now().add(const Duration(days: 5)),
        arrivalTime: DateTime.now().add(const Duration(days: 5, hours: 2)),
        durationMinutes: 120,
        stops: 0,
        aircraft: 'Airbus A321neo',
        basePrice: 5000.0,
        fares: [testFare],
      );
    });

    test('calculates base fare correctly for adult, child, and infant', () {
      final passengers = [
        const Passenger(id: '1', firstName: 'Adult', lastName: 'One', type: 'Adult'),
        const Passenger(id: '2', firstName: 'Child', lastName: 'Two', type: 'Child'),
        const Passenger(id: '3', firstName: 'Infant', lastName: 'Three', type: 'Infant'),
      ];

      // Multipliers: Adult = 1.0 (5000), Child = 0.75 (3750), Infant = 0.10 (500)
      // Total base fare = 5000 + 3750 + 500 = 9250
      final pricing = PricingService.calculate(
        flight: testFlight,
        fareOption: testFare,
        passengers: passengers,
      );

      expect(pricing.baseFare, equals(9250.0));
      expect(pricing.grandTotal, greaterThan(pricing.baseFare)); // Includes taxes & surcharges
    });

    test('applies student discount correctly on base fare', () {
      final passengers = [
        const Passenger(id: '1', firstName: 'Student', lastName: 'User', type: 'Adult'),
      ];

      final pricing = PricingService.calculate(
        flight: testFlight,
        fareOption: testFare,
        passengers: passengers,
        fareType: 'Student', // 10% discount on base fare
      );

      // Base fare 5000 * 0.90 = 4500
      expect(pricing.baseFare, equals(4500.0));
    });

    test('applies promo code flat discount', () {
      final passengers = [
        const Passenger(id: '1', firstName: 'Test', lastName: 'User', type: 'Adult'),
      ];

      const offer = Offer(
        code: 'UPIPAY',
        title: 'UPI Discount',
        description: 'Flat 250 off',
        category: 'Bank offers',
        flatDiscount: 250.0,
        minBookingAmount: 2000.0,
        badge: 'UPI',
        expiry: '2026',
      );

      final pricing = PricingService.calculate(
        flight: testFlight,
        fareOption: testFare,
        passengers: passengers,
        appliedOffer: offer,
      );

      expect(pricing.promoDiscount, equals(250.0));
    });
  });

  group('RefundService Unit Tests', () {
    test('refund > 24 hours returns 80% base fare + taxes minus fee', () {
      final origin = AirportData.findByCode('DEL')!;
      final dest = AirportData.findByCode('BOM')!;
      final flight = Flight(
        flightNumber: 'IA-204',
        origin: origin,
        destination: dest,
        departureTime: DateTime.now().add(const Duration(hours: 48)),
        arrivalTime: DateTime.now().add(const Duration(hours: 50)),
        durationMinutes: 120,
        stops: 0,
        aircraft: 'Airbus A321neo',
        basePrice: 5000.0,
        fares: const [],
      );

      final booking = Booking(
        pnr: 'IA7K9P',
        flight: flight,
        passengers: const [
          Passenger(id: '1', firstName: 'A', lastName: 'B', type: 'Adult'),
        ],
        fareFamily: 'Economy Saver',
        travelClass: 'Economy',
        status: BookingStatus.confirmed,
        bookingDate: DateTime.now().subtract(const Duration(days: 1)),
        contactEmail: 'test@example.com',
        contactPhone: '9876543210',
        pricing: const PricingBreakdown(
          baseFare: 5000.0,
          taxesAndFees: 600.0,
          fuelSurcharge: 450.0,
          convenienceFee: 350.0,
          grandTotal: 6400.0,
        ),
        paymentMethod: 'UPI',
      );

      final result = RefundService.calculateCancellationRefund(
        booking,
        cancellationTime: DateTime.now(),
      );

      // Base fare 5000 * 0.80 = 4000
      expect(result.baseFareRefund, equals(4000.0));
      expect(result.cancellationFee, equals(1500.0));
      expect(result.totalRefund, equals(4000.0 + 600.0 - 1500.0)); // 3100.0
    });

    test('refund < 2 hours gives zero base fare refund (last minute / no show)', () {
      final origin = AirportData.findByCode('DEL')!;
      final dest = AirportData.findByCode('BOM')!;
      final flight = Flight(
        flightNumber: 'IA-204',
        origin: origin,
        destination: dest,
        departureTime: DateTime.now().add(const Duration(minutes: 60)), // 1 hour away
        arrivalTime: DateTime.now().add(const Duration(minutes: 180)),
        durationMinutes: 120,
        stops: 0,
        aircraft: 'Airbus A321neo',
        basePrice: 5000.0,
        fares: const [],
      );

      final booking = Booking(
        pnr: 'IA7K9P',
        flight: flight,
        passengers: const [
          Passenger(id: '1', firstName: 'A', lastName: 'B', type: 'Adult'),
        ],
        fareFamily: 'Economy Saver',
        travelClass: 'Economy',
        status: BookingStatus.confirmed,
        bookingDate: DateTime.now().subtract(const Duration(days: 1)),
        contactEmail: 'test@example.com',
        contactPhone: '9876543210',
        pricing: const PricingBreakdown(
          baseFare: 5000.0,
          taxesAndFees: 600.0,
          fuelSurcharge: 450.0,
          convenienceFee: 350.0,
          grandTotal: 6400.0,
        ),
        paymentMethod: 'UPI',
      );

      final result = RefundService.calculateCancellationRefund(
        booking,
        cancellationTime: DateTime.now(),
      );

      expect(result.baseFareRefund, equals(0.0));
      expect(result.totalRefund, equals(600.0)); // Only airport taxes refunded
    });
  });
}

