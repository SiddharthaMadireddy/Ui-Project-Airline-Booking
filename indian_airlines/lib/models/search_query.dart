import 'airport.dart';

enum TripType { oneWay, roundTrip, multiCity }

/// Flight search query criteria
class SearchQuery {
  final TripType tripType;
  final Airport? origin;
  final Airport? destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int adults;
  final int children;
  final int infants;
  final String travelClass; // 'Economy', 'Premium Economy', 'Business'
  final String fareType; // 'Regular', 'Student', 'Senior Citizen', 'Armed Forces'
  final String? promoCode;

  SearchQuery({
    this.tripType = TripType.oneWay,
    this.origin,
    this.destination,
    DateTime? departureDate,
    this.returnDate,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.travelClass = 'Economy',
    this.fareType = 'Regular',
    this.promoCode,
  }) : departureDate = departureDate ?? DateTime.now().add(const Duration(days: 3));

  int get totalPassengers => adults + children + infants;

  SearchQuery copyWith({
    TripType? tripType,
    Airport? origin,
    Airport? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    int? adults,
    int? children,
    int? infants,
    String? travelClass,
    String? fareType,
    String? promoCode,
  }) {
    return SearchQuery(
      tripType: tripType ?? this.tripType,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      travelClass: travelClass ?? this.travelClass,
      fareType: fareType ?? this.fareType,
      promoCode: promoCode ?? this.promoCode,
    );
  }
}
