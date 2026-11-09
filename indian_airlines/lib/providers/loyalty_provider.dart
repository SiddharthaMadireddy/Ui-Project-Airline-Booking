import 'package:flutter/material.dart';

/// Provider for "Skyward Club" loyalty program calculations and membership
class LoyaltyProvider extends ChangeNotifier {
  String _tier = 'Gold';
  int _pointsBalance = 3450;
  int _tierPoints = 18200;

  String get tier => _tier;
  int get pointsBalance => _pointsBalance;
  int get tierPoints => _tierPoints;

  // Tier thresholds
  int get silverThreshold => 0;
  int get goldThreshold => 15000;
  int get platinumThreshold => 35000;

  double get tierProgress {
    if (_tier == 'Platinum') return 1.0;
    if (_tier == 'Gold') {
      return ((_tierPoints - 15000) / 20000).clamp(0.0, 1.0);
    }
    return (_tierPoints / 15000).clamp(0.0, 1.0);
  }

  /// Calculate loyalty points earned for a flight
  static int calculateEarnedPoints({
    required double baseFare,
    required String travelClass,
  }) {
    // 5 pts per ₹100 for Economy, 8 for Premium Economy, 12 for Business
    double multiplier = 0.05;
    if (travelClass.contains('Premium')) {
      multiplier = 0.08;
    } else if (travelClass.contains('Business')) {
      multiplier = 0.12;
    }
    return (baseFare * multiplier).round();
  }

  /// Interactive calculator: estimates points earned by route distance and cabin class
  static int estimatePointsByDistance({
    required double distanceKm,
    required String travelClass,
  }) {
    double factor = 1.0;
    if (travelClass == 'Business') {
      factor = 2.0;
    } else if (travelClass == 'Premium Economy') {
      factor = 1.3;
    }
    return (distanceKm * 0.75 * factor).round();
  }

  void addPoints(int points) {
    _pointsBalance += points;
    _tierPoints += points;
    _updateTier();
    notifyListeners();
  }

  void deductPoints(int points) {
    if (_pointsBalance >= points) {
      _pointsBalance -= points;
      notifyListeners();
    }
  }

  void _updateTier() {
    if (_tierPoints >= platinumThreshold) {
      _tier = 'Platinum';
    } else if (_tierPoints >= goldThreshold) {
      _tier = 'Gold';
    } else {
      _tier = 'Silver';
    }
  }
}
