import 'airport.dart';
import 'fare.dart';

/// Flight model representing a single flight segment or non-stop flight
class Flight {
  final String flightNumber; // e.g. "IA-204"
  final Airport origin;
  final Airport destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int durationMinutes;
  final int stops; // 0 = non-stop, 1 = 1 stop
  final String? viaHub; // Airport code if 1 stop
  final String aircraft;
  final double basePrice;
  final List<FareOption> fares;
  final int seatsAvailable;

  const Flight({
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.stops,
    this.viaHub,
    required this.aircraft,
    required this.basePrice,
    required this.fares,
    this.seatsAvailable = 42,
  });

  bool get isNonStop => stops == 0;

  Map<String, dynamic> toJson() => {
        'flightNumber': flightNumber,
        'origin': origin.toJson(),
        'destination': destination.toJson(),
        'departureTime': departureTime.toIso8601String(),
        'arrivalTime': arrivalTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'stops': stops,
        'viaHub': viaHub,
        'aircraft': aircraft,
        'basePrice': basePrice,
        'fares': fares.map((f) => f.toJson()).toList(),
        'seatsAvailable': seatsAvailable,
      };

  factory Flight.fromJson(Map<String, dynamic> json) => Flight(
        flightNumber: json['flightNumber'] as String,
        origin: Airport.fromJson(json['origin'] as Map<String, dynamic>),
        destination:
            Airport.fromJson(json['destination'] as Map<String, dynamic>),
        departureTime: DateTime.parse(json['departureTime'] as String),
        arrivalTime: DateTime.parse(json['arrivalTime'] as String),
        durationMinutes: json['durationMinutes'] as int,
        stops: json['stops'] as int? ?? 0,
        viaHub: json['viaHub'] as String?,
        aircraft: json['aircraft'] as String,
        basePrice: (json['basePrice'] as num).toDouble(),
        fares: (json['fares'] as List<dynamic>)
            .map((f) => FareOption.fromJson(f as Map<String, dynamic>))
            .toList(),
        seatsAvailable: json['seatsAvailable'] as int? ?? 42,
      );

  Flight copyWith({
    String? flightNumber,
    Airport? origin,
    Airport? destination,
    DateTime? departureTime,
    DateTime? arrivalTime,
    int? durationMinutes,
    int? stops,
    String? viaHub,
    String? aircraft,
    double? basePrice,
    List<FareOption>? fares,
    int? seatsAvailable,
  }) {
    return Flight(
      flightNumber: flightNumber ?? this.flightNumber,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      stops: stops ?? this.stops,
      viaHub: viaHub ?? this.viaHub,
      aircraft: aircraft ?? this.aircraft,
      basePrice: basePrice ?? this.basePrice,
      fares: fares ?? this.fares,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
    );
  }
}
