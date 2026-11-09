import 'package:flutter_test/flutter_test.dart';
import 'package:indian_airlines/data/airports.dart';
import 'package:indian_airlines/data/flight_generator.dart';
import 'package:indian_airlines/providers/search_provider.dart';
import 'package:indian_airlines/providers/trips_provider.dart';

void main() {
  group('FlightGenerator & Business Rules Tests', () {
    test('flight generator is strictly deterministic for identical origin, destination and date', () {
      final origin = AirportData.findByCode('DEL')!;
      final dest = AirportData.findByCode('BOM')!;
      final date = DateTime(2026, 12, 15);

      final run1 = FlightGenerator.generate(origin: origin, destination: dest, date: date);
      final run2 = FlightGenerator.generate(origin: origin, destination: dest, date: date);

      expect(run1.length, equals(run2.length));
      for (int i = 0; i < run1.length; i++) {
        expect(run1[i].flightNumber, equals(run2[i].flightNumber));
        expect(run1[i].basePrice, equals(run2[i].basePrice));
        expect(run1[i].departureTime, equals(run2[i].departureTime));
        expect(run1[i].aircraft, equals(run2[i].aircraft));
      }
    });

    test('check-in window logic allows check-in strictly between 2h and 48h before departure', () {
      final now = DateTime.now();

      // In window: 18 hours from now
      final eligibleTime = now.add(const Duration(hours: 18));
      expect(TripsProvider.isEligibleForCheckIn(eligibleTime), isTrue);

      // Too early: 50 hours from now
      final tooEarly = now.add(const Duration(hours: 50));
      expect(TripsProvider.isEligibleForCheckIn(tooEarly), isFalse);

      // Too late / Gate closed: 1 hour from now
      final tooLate = now.add(const Duration(minutes: 60));
      expect(TripsProvider.isEligibleForCheckIn(tooLate), isFalse);
    });

    test('passenger rules enforce max 9 total and infants <= adults', () {
      final search = SearchProvider();

      // Initial state: 1 adult, 0 children, 0 infants
      expect(search.query.totalPassengers, equals(1));

      // Attempt to add infant when adults = 1
      search.updatePassengers(adults: 1, children: 0, infants: 1);
      expect(search.query.infants, equals(1));

      // Attempt to set 2 infants with only 1 adult -> clamped to 1
      search.updatePassengers(adults: 1, children: 0, infants: 2);
      expect(search.query.infants, equals(1));

      // Maximum 9 total passengers
      search.updatePassengers(adults: 6, children: 3, infants: 0); // 9 total
      expect(search.canAddAdult(), isFalse);
      expect(search.canAddChild(), isFalse);
    });
  });
}

