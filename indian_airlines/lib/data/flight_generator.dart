import 'dart:math';
import '../models/airport.dart';
import '../models/fare.dart';
import '../models/flight.dart';

/// Deterministic flight generator: given origin, destination and date,
/// always returns the exact same list of 8-12 realistic flights.
class FlightGenerator {
  /// Simple 32-bit string hash code to guarantee deterministic cross-platform behavior
  static int _hash(String str) {
    int h = 0;
    for (int i = 0; i < str.length; i++) {
      h = (31 * h + str.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return h;
  }

  /// Approximate great circle distance in kilometers
  static double _calculateDistance(Airport a, Airport b) {
    const double r = 6371; // Earth radius in km
    final double lat1 = a.latitude * pi / 180;
    final double lon1 = a.longitude * pi / 180;
    final double lat2 = b.latitude * pi / 180;
    final double lon2 = b.longitude * pi / 180;

    final double dlat = lat2 - lat1;
    final double dlon = lon2 - lon1;

    final double sinDlat = sin(dlat / 2);
    final double sinDlon = sin(dlon / 2);

    final double haversine =
        sinDlat * sinDlat + cos(lat1) * cos(lat2) * sinDlon * sinDlon;
    final double c = 2 * atan2(sqrt(haversine), sqrt(1 - haversine));
    final double dist = r * c;
    return dist > 100 ? dist : 800; // default min distance if coordinates unavailable
  }

  static List<Flight> generate({
    required Airport origin,
    required Airport destination,
    required DateTime date,
  }) {
    final String seedKey =
        '${origin.code}_${destination.code}_${date.year}_${date.month}_${date.day}';
    final Random rng = Random(_hash(seedKey));

    final double distanceKm = _calculateDistance(origin, destination);
    final bool isInternational = !origin.isDomestic || !destination.isDomestic;

    // Flight count between 8 and 12
    final int flightCount = 8 + rng.nextInt(5);

    final List<String> domesticAircrafts = [
      'Airbus A321neo',
      'Airbus A320neo',
      'Boeing 737 MAX 8',
      'Boeing 787-9 Dreamliner',
    ];

    final List<String> internationalAircrafts = [
      'Boeing 787-9 Dreamliner',
      'Airbus A350-900',
      'Boeing 777-300ER',
      'Airbus A321XLR',
    ];

    final List<String> hubCodes = ['DEL', 'BOM', 'BLR', 'HYD', 'DXB'];

    final List<Flight> flights = [];

    // Base fare estimated by distance
    final double calculatedBase = isInternational
        ? max(12000.0, distanceKm * 4.8)
        : max(2800.0, distanceKm * 2.9);

    // Approximate flight duration in minutes
    final int directDurationMinutes =
        (40 + (distanceKm / 750 * 60)).round();

    for (int i = 0; i < flightCount; i++) {
      // Deterministic flight number between IA-101 and IA-989
      final int flightNum = 100 + ((rng.nextInt(890) + i * 23) % 890);
      final String code = 'IA-$flightNum';

      // Departure hours spread: 05:00 to 22:30
      final int depHour = 5 + ((i * 17) % 18);
      final int depMin = ((i * 20 + rng.nextInt(15)) ~/ 5) * 5 % 60;
      final DateTime departure = DateTime(
        date.year,
        date.month,
        date.day,
        depHour,
        depMin,
      );

      // Roughly 70% non-stop, 30% 1-stop
      final bool isNonStop = (i % 3 != 2);
      final int stops = isNonStop ? 0 : 1;
      String? viaHub;
      int durationMinutes = directDurationMinutes;

      if (!isNonStop) {
        // Layover adds 75-150 minutes
        final int layover = 75 + rng.nextInt(60);
        durationMinutes += layover;
        final possibleHubs = hubCodes
            .where((h) => h != origin.code && h != destination.code)
            .toList();
        viaHub = possibleHubs[rng.nextInt(possibleHubs.length)];
      }

      final DateTime arrival = departure.add(Duration(minutes: durationMinutes));

      final aircraftList =
          isInternational ? internationalAircrafts : domesticAircrafts;
      final aircraft = aircraftList[rng.nextInt(aircraftList.length)];

      // Pricing variations per flight timing (prime hours slightly higher)
      final double timingMultiplier =
          (depHour >= 8 && depHour <= 10) || (depHour >= 18 && depHour <= 20)
              ? 1.15
              : (depHour >= 5 && depHour <= 7 ? 0.92 : 1.0);

      final double stopMultiplier = isNonStop ? 1.08 : 0.94;
      final double randomFuzz = 0.95 + (rng.nextInt(12) / 100.0);

      final double basePrice =
          ((calculatedBase * timingMultiplier * stopMultiplier * randomFuzz) /
                      50)
                  .round() *
              50.0;

      // 3 Fare Families
      final fares = [
        FareOption(
          type: FareFamilyType.saver,
          name: 'Economy Saver',
          price: basePrice,
          cabinBaggage: '7 kg',
          checkInBaggage: isInternational ? '25 kg' : '15 kg',
          seatSelection: 'Chargeable',
          meal: 'Chargeable',
          cancellationFee: 3000.0,
          changeFee: 2500.0,
          refundRule: 'Non-refundable if cancelled <24h. ₹3,000 fee for >24h.',
          benefits: const [
            '7 kg Cabin baggage',
            '15 kg Standard check-in',
            'Standard seat selection',
          ],
        ),
        FareOption(
          type: FareFamilyType.flex,
          name: 'Economy Flex',
          price: ((basePrice * 1.25) / 50).round() * 50.0,
          cabinBaggage: '7 kg',
          checkInBaggage: isInternational ? '35 kg' : '25 kg',
          seatSelection: 'Standard Free',
          meal: 'Complimentary Snack',
          cancellationFee: 1500.0,
          changeFee: 0.0,
          refundRule: 'Low fee cancellation up to 4h before departure.',
          benefits: const [
            'Free date changes up to 4h',
            'Complimentary snack & drink',
            '25 kg Check-in baggage',
            'Free standard seat selection',
          ],
        ),
        FareOption(
          type: FareFamilyType.business,
          name: 'Business Class',
          price: ((basePrice * 2.40) / 100).round() * 100.0,
          cabinBaggage: '12 kg',
          checkInBaggage: isInternational ? '40 kg' : '35 kg',
          seatSelection: 'Premium Free',
          meal: 'Gourmet 3-Course Dining',
          cancellationFee: 1000.0,
          changeFee: 0.0,
          refundRule: 'Fully refundable minus ₹1000 administrative fee.',
          benefits: const [
            'Lie-flat / recliner wide seats',
            'Airport lounge access',
            'Priority check-in & boarding',
            'Gourmet dining with beverages',
            '35 kg Check-in allowance',
          ],
        ),
      ];

      final int seatsAvailable = 15 + rng.nextInt(35);

      flights.add(
        Flight(
          flightNumber: code,
          origin: origin,
          destination: destination,
          departureTime: departure,
          arrivalTime: arrival,
          durationMinutes: durationMinutes,
          stops: stops,
          viaHub: viaHub,
          aircraft: aircraft,
          basePrice: basePrice,
          fares: fares,
          seatsAvailable: seatsAvailable,
        ),
      );
    }

    // Sort by departure time initially
    flights.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    return flights;
  }

  /// Generate lowest fare estimates for a 7-day strip centered around the selected date
  static Map<DateTime, double> generate7DayFares({
    required Airport origin,
    required Airport destination,
    required DateTime centerDate,
  }) {
    final Map<DateTime, double> dailyFares = {};
    for (int offset = -3; offset <= 3; offset++) {
      final targetDate = centerDate.add(Duration(days: offset));
      // Only for present or future dates
      final normalizedDate =
          DateTime(targetDate.year, targetDate.month, targetDate.day);
      final flights = generate(
        origin: origin,
        destination: destination,
        date: normalizedDate,
      );
      if (flights.isNotEmpty) {
        final lowest = flights.map((f) => f.basePrice).reduce(min);
        dailyFares[normalizedDate] = lowest;
      }
    }
    return dailyFares;
  }
}
