/// Airport model for domestic and international airports
class Airport {
  final String code;
  final String city;
  final String name;
  final String country;
  final bool isDomestic;
  final bool isHub;
  final double latitude;
  final double longitude;

  const Airport({
    required this.code,
    required this.city,
    required this.name,
    required this.country,
    this.isDomestic = true,
    this.isHub = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  String get displayName => '$city ($code) - $name';
  String get shortName => '$city ($code)';

  Map<String, dynamic> toJson() => {
        'code': code,
        'city': city,
        'name': name,
        'country': country,
        'isDomestic': isDomestic,
        'isHub': isHub,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Airport.fromJson(Map<String, dynamic> json) => Airport(
        code: json['code'] as String,
        city: json['city'] as String,
        name: json['name'] as String,
        country: json['country'] as String? ?? 'India',
        isDomestic: json['isDomestic'] as bool? ?? true,
        isHub: json['isHub'] as bool? ?? false,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      );

  Airport copyWith({
    String? code,
    String? city,
    String? name,
    String? country,
    bool? isDomestic,
    bool? isHub,
    double? latitude,
    double? longitude,
  }) {
    return Airport(
      code: code ?? this.code,
      city: city ?? this.city,
      name: name ?? this.name,
      country: country ?? this.country,
      isDomestic: isDomestic ?? this.isDomestic,
      isHub: isHub ?? this.isHub,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Airport &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
