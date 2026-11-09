import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/passenger.dart';
import '../services/seat_service.dart';

/// Interactive seat selection map with passenger switching and seat type legend
class SeatMapWidget extends StatefulWidget {
  final String flightNumber;
  final DateTime flightDate;
  final List<Passenger> passengers;
  final void Function(String passengerId, String seatCode) onSeatSelected;

  const SeatMapWidget({
    super.key,
    required this.flightNumber,
    required this.flightDate,
    required this.passengers,
    required this.onSeatSelected,
  });

  @override
  State<SeatMapWidget> createState() => _SeatMapWidgetState();
}

class _SeatMapWidgetState extends State<SeatMapWidget> {
  late List<SeatInfo> _seatMap;
  int _activePassengerIndex = 0;

  @override
  void initState() {
    super.initState();
    _seatMap = SeatService.generateSeatMap(
      flightNumber: widget.flightNumber,
      date: widget.flightDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePassenger = widget.passengers.isNotEmpty
        ? widget.passengers[_activePassengerIndex]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Passenger Selector Chips
        if (widget.passengers.length > 1) ...[
          const Text(
            'Select passenger to assign seat:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.passengers.length, (index) {
                final p = widget.passengers[index];
                final isSelected = index == _activePassengerIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(
                      '${p.fullName.isNotEmpty ? p.fullName : 'Passenger ${index + 1}'}: ${p.seatNumber ?? 'No seat'}',
                    ),
                    selected: isSelected,
                    selectedColor: AppConstants.saffron.withValues(alpha: 0.3),
                    onSelected: (_) {
                      setState(() {
                        _activePassengerIndex = index;
                      });
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 2. Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildLegendItem('Available', Colors.white, AppConstants.borderDark),
            _buildLegendItem('Occupied', Colors.grey.shade400, Colors.grey),
            _buildLegendItem('Selected', AppConstants.saffron, AppConstants.saffron),
            _buildLegendItem('Extra Legroom (₹600)', const Color(0xFFE0F2FE), Colors.blue),
            _buildLegendItem('Business Class', const Color(0xFFFEF3C7), Colors.amber),
          ],
        ),
        const SizedBox(height: 20),

        // 3. Airplane Fuselage Container
        Container(
          width: 360,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(80),
              bottom: Radius.circular(20),
            ),
            border: Border.all(color: AppConstants.primaryNavy, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Cockpit Visual
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: AppConstants.primaryNavy.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'FRONT OF AIRCRAFT',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 12),

              // Seat Rows
              _buildSeatsGrid(activePassenger),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color fill, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildSeatsGrid(Passenger? activePassenger) {
    // Group seats by row
    final Map<int, List<SeatInfo>> rows = {};
    for (final s in _seatMap) {
      rows.putIfAbsent(s.row, () => []).add(s);
    }

    final sortedRows = rows.keys.toList()..sort();

    return Column(
      children: sortedRows.map((rowNum) {
        final rowSeats = rows[rowNum]!;
        final bool isBusiness = rowNum <= 3;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row number indicator
              SizedBox(
                width: 24,
                child: Text(
                  '$rowNum',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),

              // Left Seats
              if (isBusiness) ...[
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'A'), activePassenger),
                const SizedBox(width: 4),
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'C'), activePassenger),
              ] else ...[
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'A'), activePassenger),
                const SizedBox(width: 4),
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'B'), activePassenger),
                const SizedBox(width: 4),
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'C'), activePassenger),
              ],

              // Aisle
              const SizedBox(width: 24),

              // Right Seats
              if (isBusiness) ...[
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'D'), activePassenger),
                const SizedBox(width: 4),
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'F'), activePassenger),
              ] else ...[
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'D'), activePassenger),
                const SizedBox(width: 4),
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'E'), activePassenger),
                const SizedBox(width: 4),
                _buildSeatTile(rowSeats.firstWhere((s) => s.column == 'F'), activePassenger),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeatTile(SeatInfo seat, Passenger? activePassenger) {
    // Check if this seat is selected by ANY passenger in booking
    final isSelectedByCurrent = activePassenger?.seatNumber == seat.code;
    final isSelectedByOther = widget.passengers.any(
      (p) => p.id != activePassenger?.id && p.seatNumber == seat.code,
    );

    Color bg;
    Color border;
    if (seat.isOccupied || isSelectedByOther) {
      bg = Colors.grey.shade300;
      border = Colors.grey.shade400;
    } else if (isSelectedByCurrent) {
      bg = AppConstants.saffron;
      border = AppConstants.primaryNavy;
    } else if (seat.type == SeatType.business) {
      bg = const Color(0xFFFEF3C7);
      border = Colors.amber.shade700;
    } else if (seat.type == SeatType.extraLegroom) {
      bg = const Color(0xFFE0F2FE);
      border = Colors.blue.shade400;
    } else {
      bg = Colors.white;
      border = Colors.grey.shade400;
    }

    return Tooltip(
      message: seat.isOccupied || isSelectedByOther
          ? 'Seat ${seat.code} (Occupied)'
          : 'Seat ${seat.code} • ${seat.type.name} • ₹${seat.price.toInt()}',
      child: InkWell(
        onTap: (seat.isOccupied || isSelectedByOther || activePassenger == null)
            ? null
            : () {
                widget.onSeatSelected(activePassenger.id, seat.code);
              },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border, width: isSelectedByCurrent ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            seat.column,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: (seat.isOccupied || isSelectedByOther)
                  ? Colors.grey.shade600
                  : (isSelectedByCurrent ? AppConstants.primaryNavy : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

