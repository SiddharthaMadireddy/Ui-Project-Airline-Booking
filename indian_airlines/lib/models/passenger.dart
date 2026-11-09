/// Passenger details model
class Passenger {
  final String id;
  final String title; // Mr, Ms, Mrs, Dr, Master
  final String firstName;
  final String lastName;
  final DateTime? dob;
  final String gender; // Male, Female, Other
  final String nationality;
  final String? passportNumber;
  final String? seatNumber;
  final String? mealPreference;
  final int extraBaggageKg;
  final bool isFrequent;
  final String type; // Adult, Child, Infant

  const Passenger({
    required this.id,
    this.title = 'Mr',
    required this.firstName,
    required this.lastName,
    this.dob,
    this.gender = 'Male',
    this.nationality = 'Indian',
    this.passportNumber,
    this.seatNumber,
    this.mealPreference,
    this.extraBaggageKg = 0,
    this.isFrequent = false,
    this.type = 'Adult',
  });

  String get fullName => '$title $firstName $lastName'.trim();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'firstName': firstName,
        'lastName': lastName,
        'dob': dob?.toIso8601String(),
        'gender': gender,
        'nationality': nationality,
        'passportNumber': passportNumber,
        'seatNumber': seatNumber,
        'mealPreference': mealPreference,
        'extraBaggageKg': extraBaggageKg,
        'isFrequent': isFrequent,
        'type': type,
      };

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        id: json['id'] as String? ?? 'p_1',
        title: json['title'] as String? ?? 'Mr',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
        gender: json['gender'] as String? ?? 'Male',
        nationality: json['nationality'] as String? ?? 'Indian',
        passportNumber: json['passportNumber'] as String?,
        seatNumber: json['seatNumber'] as String?,
        mealPreference: json['mealPreference'] as String?,
        extraBaggageKg: json['extraBaggageKg'] as int? ?? 0,
        isFrequent: json['isFrequent'] as bool? ?? false,
        type: json['type'] as String? ?? 'Adult',
      );

  Passenger copyWith({
    String? id,
    String? title,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? gender,
    String? nationality,
    String? passportNumber,
    String? seatNumber,
    String? mealPreference,
    int? extraBaggageKg,
    bool? isFrequent,
    String? type,
  }) {
    return Passenger(
      id: id ?? this.id,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      passportNumber: passportNumber ?? this.passportNumber,
      seatNumber: seatNumber ?? this.seatNumber,
      mealPreference: mealPreference ?? this.mealPreference,
      extraBaggageKg: extraBaggageKg ?? this.extraBaggageKg,
      isFrequent: isFrequent ?? this.isFrequent,
      type: type ?? this.type,
    );
  }
}
