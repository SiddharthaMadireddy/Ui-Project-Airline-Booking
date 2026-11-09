import 'package:flutter/material.dart';

/// Featured destination card data for "Book Nonstop Direct Flights"
class DestinationCardData {
  final String code;
  final String city;
  final String country;
  final double startingFare;
  final String tagline;
  final String defaultOriginCode;
  final List<Color> gradientColors;
  final IconData icon;

  const DestinationCardData({
    required this.code,
    required this.city,
    required this.country,
    required this.startingFare,
    required this.tagline,
    required this.defaultOriginCode,
    required this.gradientColors,
    required this.icon,
  });
}

class DestinationsData {
  static const List<DestinationCardData> destinations = [
    // 7 Domestic
    DestinationCardData(
      code: 'DEL',
      city: 'Delhi',
      country: 'India',
      startingFare: 3499,
      tagline: 'Heart of the Nation & Historic Monuments',
      defaultOriginCode: 'BOM',
      gradientColors: [Color(0xFF0B1F4B), Color(0xFF1E3A8A)],
      icon: Icons.account_balance,
    ),
    DestinationCardData(
      code: 'BOM',
      city: 'Mumbai',
      country: 'India',
      startingFare: 3299,
      tagline: 'The Maximum City & Marine Drive',
      defaultOriginCode: 'DEL',
      gradientColors: [Color(0xFF0F172A), Color(0xFF2563EB)],
      icon: Icons.location_city,
    ),
    DestinationCardData(
      code: 'BLR',
      city: 'Bengaluru',
      country: 'India',
      startingFare: 2999,
      tagline: 'Garden City & Technology Capital',
      defaultOriginCode: 'DEL',
      gradientColors: [Color(0xFF064E3B), Color(0xFF059669)],
      icon: Icons.park,
    ),
    DestinationCardData(
      code: 'HYD',
      city: 'Hyderabad',
      country: 'India',
      startingFare: 2899,
      tagline: 'City of Pearls & Royal Heritage',
      defaultOriginCode: 'BLR',
      gradientColors: [Color(0xFF78350F), Color(0xFFD97706)],
      icon: Icons.fort,
    ),
    DestinationCardData(
      code: 'GOI',
      city: 'Goa',
      country: 'India',
      startingFare: 3199,
      tagline: 'Sun-drenched Beaches & Coastal Vibes',
      defaultOriginCode: 'BOM',
      gradientColors: [Color(0xFF0E7490), Color(0xFF06B6D4)],
      icon: Icons.beach_access,
    ),
    DestinationCardData(
      code: 'CCU',
      city: 'Kolkata',
      country: 'India',
      startingFare: 3599,
      tagline: 'City of Joy & Cultural Legacy',
      defaultOriginCode: 'DEL',
      gradientColors: [Color(0xFF581C87), Color(0xFF9333EA)],
      icon: Icons.museum,
    ),
    DestinationCardData(
      code: 'MAA',
      city: 'Chennai',
      country: 'India',
      startingFare: 3199,
      tagline: 'Gateway to the South & Marina Beach',
      defaultOriginCode: 'DEL',
      gradientColors: [Color(0xFF1E293B), Color(0xFF475569)],
      icon: Icons.temple_hindu,
    ),

    // 5 International
    DestinationCardData(
      code: 'DXB',
      city: 'Dubai',
      country: 'United Arab Emirates',
      startingFare: 14999,
      tagline: 'Futuristic Skyline & Desert Glitz',
      defaultOriginCode: 'BOM',
      gradientColors: [Color(0xFF831843), Color(0xFFDB2777)],
      icon: Icons.star,
    ),
    DestinationCardData(
      code: 'SIN',
      city: 'Singapore',
      country: 'Singapore',
      startingFare: 16499,
      tagline: 'World-class Dining & Marina Bay',
      defaultOriginCode: 'BLR',
      gradientColors: [Color(0xFF14532D), Color(0xFF16A34A)],
      icon: Icons.eco,
    ),
    DestinationCardData(
      code: 'LHR',
      city: 'London',
      country: 'United Kingdom',
      startingFare: 42999,
      tagline: 'Big Ben, West End & Royal Palaces',
      defaultOriginCode: 'DEL',
      gradientColors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
      icon: Icons.apartment,
    ),
    DestinationCardData(
      code: 'HND',
      city: 'Tokyo',
      country: 'Japan',
      startingFare: 38999,
      tagline: 'Cherry Blossoms, Tech & Shrines',
      defaultOriginCode: 'DEL',
      gradientColors: [Color(0xFF881337), Color(0xFFE11D48)],
      icon: Icons.flare,
    ),
    DestinationCardData(
      code: 'DPS',
      city: 'Bali',
      country: 'Indonesia',
      startingFare: 19999,
      tagline: 'Tropical Temples & Surfing Paradises',
      defaultOriginCode: 'BOM',
      gradientColors: [Color(0xFF042F2E), Color(0xFF0D9488)],
      icon: Icons.waves,
    ),
  ];
}
