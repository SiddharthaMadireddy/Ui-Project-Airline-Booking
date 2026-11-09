import 'flight.dart';
import 'passenger.dart';

enum BookingStatus { confirmed, cancelled, completed }

/// Pricing breakdown of fares, taxes, surcharges and add-ons
class PricingBreakdown {
  final double baseFare;
  final double taxesAndFees; // Airport tax + GST
  final double fuelSurcharge;
  final double convenienceFee;
  final double seatSelectionTotal;
  final double mealsTotal;
  final double baggageTotal;
  final double insuranceTotal;
  final double priorityBoardingTotal;
  final double promoDiscount;
  final double pointsDiscount;
  final double grandTotal;

  const PricingBreakdown({
    required this.baseFare,
    required this.taxesAndFees,
    required this.fuelSurcharge,
    required this.convenienceFee,
    this.seatSelectionTotal = 0.0,
    this.mealsTotal = 0.0,
    this.baggageTotal = 0.0,
    this.insuranceTotal = 0.0,
    this.priorityBoardingTotal = 0.0,
    this.promoDiscount = 0.0,
    this.pointsDiscount = 0.0,
    required this.grandTotal,
  });

  Map<String, dynamic> toJson() => {
        'baseFare': baseFare,
        'taxesAndFees': taxesAndFees,
        'fuelSurcharge': fuelSurcharge,
        'convenienceFee': convenienceFee,
        'seatSelectionTotal': seatSelectionTotal,
        'mealsTotal': mealsTotal,
        'baggageTotal': baggageTotal,
        'insuranceTotal': insuranceTotal,
        'priorityBoardingTotal': priorityBoardingTotal,
        'promoDiscount': promoDiscount,
        'pointsDiscount': pointsDiscount,
        'grandTotal': grandTotal,
      };

  factory PricingBreakdown.fromJson(Map<String, dynamic> json) =>
      PricingBreakdown(
        baseFare: (json['baseFare'] as num).toDouble(),
        taxesAndFees: (json['taxesAndFees'] as num).toDouble(),
        fuelSurcharge: (json['fuelSurcharge'] as num).toDouble(),
        convenienceFee: (json['convenienceFee'] as num).toDouble(),
        seatSelectionTotal:
            (json['seatSelectionTotal'] as num?)?.toDouble() ?? 0.0,
        mealsTotal: (json['mealsTotal'] as num?)?.toDouble() ?? 0.0,
        baggageTotal: (json['baggageTotal'] as num?)?.toDouble() ?? 0.0,
        insuranceTotal: (json['insuranceTotal'] as num?)?.toDouble() ?? 0.0,
        priorityBoardingTotal:
            (json['priorityBoardingTotal'] as num?)?.toDouble() ?? 0.0,
        promoDiscount: (json['promoDiscount'] as num?)?.toDouble() ?? 0.0,
        pointsDiscount: (json['pointsDiscount'] as num?)?.toDouble() ?? 0.0,
        grandTotal: (json['grandTotal'] as num).toDouble(),
      );
}

/// Boarding pass data generated upon web check-in
class BoardingPassData {
  final String passengerName;
  final String pnr;
  final String flightNumber;
  final String seat;
  final String boardingGroup;
  final String gate;
  final DateTime boardingTime;
  final String originCode;
  final String destinationCode;
  final String terminal;

  const BoardingPassData({
    required this.passengerName,
    required this.pnr,
    required this.flightNumber,
    required this.seat,
    required this.boardingGroup,
    required this.gate,
    required this.boardingTime,
    required this.originCode,
    required this.destinationCode,
    required this.terminal,
  });

  Map<String, dynamic> toJson() => {
        'passengerName': passengerName,
        'pnr': pnr,
        'flightNumber': flightNumber,
        'seat': seat,
        'boardingGroup': boardingGroup,
        'gate': gate,
        'boardingTime': boardingTime.toIso8601String(),
        'originCode': originCode,
        'destinationCode': destinationCode,
        'terminal': terminal,
      };

  factory BoardingPassData.fromJson(Map<String, dynamic> json) =>
      BoardingPassData(
        passengerName: json['passengerName'] as String,
        pnr: json['pnr'] as String,
        flightNumber: json['flightNumber'] as String,
        seat: json['seat'] as String,
        boardingGroup: json['boardingGroup'] as String,
        gate: json['gate'] as String,
        boardingTime: DateTime.parse(json['boardingTime'] as String),
        originCode: json['originCode'] as String,
        destinationCode: json['destinationCode'] as String,
        terminal: json['terminal'] as String? ?? 'T3',
      );
}

/// Complete Booking record with flights, passengers, add-ons and payment status
class Booking {
  final String pnr; // 6 alphanumeric characters
  final Flight flight;
  final Flight? returnFlight;
  final List<Passenger> passengers;
  final String fareFamily; // Saver, Flex, Business
  final String travelClass; // Economy, Premium Economy, Business
  final BookingStatus status;
  final DateTime bookingDate;
  final String contactEmail;
  final String contactPhone;
  final String? gstNumber;
  final String? companyName;
  final bool hasInsurance;
  final bool hasPriorityBoarding;
  final PricingBreakdown pricing;
  final String paymentMethod;
  final bool isCheckedIn;
  final List<BoardingPassData> boardingPasses;
  final double? refundAmount;
  final DateTime? cancellationDate;

  const Booking({
    required this.pnr,
    required this.flight,
    this.returnFlight,
    required this.passengers,
    required this.fareFamily,
    required this.travelClass,
    this.status = BookingStatus.confirmed,
    required this.bookingDate,
    required this.contactEmail,
    required this.contactPhone,
    this.gstNumber,
    this.companyName,
    this.hasInsurance = false,
    this.hasPriorityBoarding = false,
    required this.pricing,
    required this.paymentMethod,
    this.isCheckedIn = false,
    this.boardingPasses = const [],
    this.refundAmount,
    this.cancellationDate,
  });

  bool get isCancelled => status == BookingStatus.cancelled;

  Map<String, dynamic> toJson() => {
        'pnr': pnr,
        'flight': flight.toJson(),
        'returnFlight': returnFlight?.toJson(),
        'passengers': passengers.map((p) => p.toJson()).toList(),
        'fareFamily': fareFamily,
        'travelClass': travelClass,
        'status': status.name,
        'bookingDate': bookingDate.toIso8601String(),
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'gstNumber': gstNumber,
        'companyName': companyName,
        'hasInsurance': hasInsurance,
        'hasPriorityBoarding': hasPriorityBoarding,
        'pricing': pricing.toJson(),
        'paymentMethod': paymentMethod,
        'isCheckedIn': isCheckedIn,
        'boardingPasses': boardingPasses.map((b) => b.toJson()).toList(),
        'refundAmount': refundAmount,
        'cancellationDate': cancellationDate?.toIso8601String(),
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        pnr: json['pnr'] as String,
        flight: Flight.fromJson(json['flight'] as Map<String, dynamic>),
        returnFlight: json['returnFlight'] != null
            ? Flight.fromJson(json['returnFlight'] as Map<String, dynamic>)
            : null,
        passengers: (json['passengers'] as List<dynamic>)
            .map((p) => Passenger.fromJson(p as Map<String, dynamic>))
            .toList(),
        fareFamily: json['fareFamily'] as String? ?? 'Saver',
        travelClass: json['travelClass'] as String? ?? 'Economy',
        status: BookingStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => BookingStatus.confirmed,
        ),
        bookingDate: DateTime.parse(json['bookingDate'] as String),
        contactEmail: json['contactEmail'] as String,
        contactPhone: json['contactPhone'] as String,
        gstNumber: json['gstNumber'] as String?,
        companyName: json['companyName'] as String?,
        hasInsurance: json['hasInsurance'] as bool? ?? false,
        hasPriorityBoarding: json['hasPriorityBoarding'] as bool? ?? false,
        pricing:
            PricingBreakdown.fromJson(json['pricing'] as Map<String, dynamic>),
        paymentMethod: json['paymentMethod'] as String? ?? 'UPI',
        isCheckedIn: json['isCheckedIn'] as bool? ?? false,
        boardingPasses: (json['boardingPasses'] as List<dynamic>?)
                ?.map((b) =>
                    BoardingPassData.fromJson(b as Map<String, dynamic>))
                .toList() ??
            const [],
        refundAmount: (json['refundAmount'] as num?)?.toDouble(),
        cancellationDate: json['cancellationDate'] != null
            ? DateTime.tryParse(json['cancellationDate'])
            : null,
      );

  Booking copyWith({
    String? pnr,
    Flight? flight,
    Flight? returnFlight,
    List<Passenger>? passengers,
    String? fareFamily,
    String? travelClass,
    BookingStatus? status,
    DateTime? bookingDate,
    String? contactEmail,
    String? contactPhone,
    String? gstNumber,
    String? companyName,
    bool? hasInsurance,
    bool? hasPriorityBoarding,
    PricingBreakdown? pricing,
    String? paymentMethod,
    bool? isCheckedIn,
    List<BoardingPassData>? boardingPasses,
    double? refundAmount,
    DateTime? cancellationDate,
  }) {
    return Booking(
      pnr: pnr ?? this.pnr,
      flight: flight ?? this.flight,
      returnFlight: returnFlight ?? this.returnFlight,
      passengers: passengers ?? this.passengers,
      fareFamily: fareFamily ?? this.fareFamily,
      travelClass: travelClass ?? this.travelClass,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      gstNumber: gstNumber ?? this.gstNumber,
      companyName: companyName ?? this.companyName,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      hasPriorityBoarding: hasPriorityBoarding ?? this.hasPriorityBoarding,
      pricing: pricing ?? this.pricing,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      boardingPasses: boardingPasses ?? this.boardingPasses,
      refundAmount: refundAmount ?? this.refundAmount,
      cancellationDate: cancellationDate ?? this.cancellationDate,
    );
  }
}
