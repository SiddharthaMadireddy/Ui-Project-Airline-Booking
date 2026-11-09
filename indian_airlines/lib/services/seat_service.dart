import 'dart:math';

enum SeatType { business, extraLegroom, standard }

class SeatInfo {
  final String code; // e.g. "4A"
  final int row;
  final String column;
  final SeatType type;
  final bool isOccupied;
  final double price;

  const SeatInfo({
    required this.code,
    required this.row,
    required this.column,
    required this.type,
    required this.isOccupied,
    required this.price,
  });
}

/// Service providing aircraft seat layouts and deterministic occupancy
class SeatService {
  static List<SeatInfo> generateSeatMap({
    required String flightNumber,
    required DateTime date,
  }) {
    // Deterministic random seed from flight and date
    final seed = flightNumber.hashCode ^
        (date.year * 10000 + date.month * 100 + date.day);
    final rng = Random(seed);

    final List<SeatInfo> seats = [];

    // Rows 1-3: Business Class (2x2: A, C, D, F)
    for (int row = 1; row <= 3; row++) {
      for (final col in ['A', 'C', 'D', 'F']) {
        final code = '$row$col';
        final isOccupied = rng.nextDouble() < 0.35;
        seats.add(
          SeatInfo(
            code: code,
            row: row,
            column: col,
            type: SeatType.business,
            isOccupied: isOccupied,
            price: 0.0, // Included in Business or upgradable
          ),
        );
      }
    }

    // Rows 4-6: Extra Legroom (3x3: A, B, C, D, E, F)
    for (int row = 4; row <= 6; row++) {
      for (final col in ['A', 'B', 'C', 'D', 'E', 'F']) {
        final code = '$row$col';
        final isOccupied = rng.nextDouble() < 0.45;
        seats.add(
          SeatInfo(
            code: code,
            row: row,
            column: col,
            type: SeatType.extraLegroom,
            isOccupied: isOccupied,
            price: 600.0,
          ),
        );
      }
    }

    // Rows 7-22: Standard Economy (3x3: A, B, C, D, E, F)
    for (int row = 7; row <= 22; row++) {
      for (final col in ['A', 'B', 'C', 'D', 'E', 'F']) {
        final code = '$row$col';
        final isOccupied = rng.nextDouble() < 0.50;
        final double price = (col == 'B' || col == 'E') ? 150.0 : 250.0;
        seats.add(
          SeatInfo(
            code: code,
            row: row,
            column: col,
            type: SeatType.standard,
            isOccupied: isOccupied,
            price: price,
          ),
        );
      }
    }

    return seats;
  }
}
