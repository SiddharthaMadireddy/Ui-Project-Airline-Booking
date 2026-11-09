import 'passenger.dart';

/// User profile and authentication model
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String skywardClubNumber;
  final String skywardTier; // 'Silver', 'Gold', 'Platinum'
  final int skywardPoints;
  final List<Passenger> savedPassengers;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.skywardClubNumber,
    this.skywardTier = 'Silver',
    this.skywardPoints = 1250,
    this.savedPassengers = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'skywardClubNumber': skywardClubNumber,
        'skywardTier': skywardTier,
        'skywardPoints': skywardPoints,
        'savedPassengers': savedPassengers.map((p) => p.toJson()).toList(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        skywardClubNumber: json['skywardClubNumber'] as String? ?? 'SK-882194',
        skywardTier: json['skywardTier'] as String? ?? 'Silver',
        skywardPoints: json['skywardPoints'] as int? ?? 1250,
        savedPassengers: (json['savedPassengers'] as List<dynamic>?)
                ?.map((p) => Passenger.fromJson(p as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? skywardClubNumber,
    String? skywardTier,
    int? skywardPoints,
    List<Passenger>? savedPassengers,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      skywardClubNumber: skywardClubNumber ?? this.skywardClubNumber,
      skywardTier: skywardTier ?? this.skywardTier,
      skywardPoints: skywardPoints ?? this.skywardPoints,
      savedPassengers: savedPassengers ?? this.savedPassengers,
    );
  }
}
