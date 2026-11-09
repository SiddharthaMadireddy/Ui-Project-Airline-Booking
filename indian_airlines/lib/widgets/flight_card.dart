import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/responsive.dart';
import '../models/fare.dart';
import '../models/flight.dart';

/// Expandable flight card displaying timings, stops, aircraft and 3 fare families
class FlightCard extends StatefulWidget {
  final Flight flight;
  final FareOption? selectedFare;
  final void Function(FareOption fare) onSelectFare;

  const FlightCard({
    super.key,
    required this.flight,
    this.selectedFare,
    required this.onSelectFare,
  });

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final isDesktop = Responsive.isDesktop(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.selectedFare != null
              ? AppConstants.primaryNavy
              : (isDark ? AppConstants.borderDark : AppConstants.borderLight),
          width: widget.selectedFare != null ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Main Overview Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Airline & Flight Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppConstants.saffron,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          flight.flightNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppConstants.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      flight.aircraft,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),

                const Spacer(),

                // Departure -> Arrival Visual
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Departure
                      Column(
                        children: [
                          Text(
                            AppFormatters.formatTime(flight.departureTime),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            flight.origin.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Duration & Stops Line
                      Column(
                        children: [
                          Text(
                            AppFormatters.formatDuration(flight.durationMinutes),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Divider(thickness: 1.5),
                                if (flight.stops == 0)
                                  const Icon(Icons.flight, size: 14, color: AppConstants.accentGreen)
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    color: isDark ? AppConstants.darkCard : Colors.white,
                                    child: Text(
                                      '1 Stop (${flight.viaHub})',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            flight.isNonStop ? 'Non-stop' : '1 Stop via ${flight.viaHub}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: flight.isNonStop ? AppConstants.accentGreen : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Arrival
                      Column(
                        children: [
                          Text(
                            AppFormatters.formatTime(flight.arrivalTime),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            flight.destination.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Price and View Fares Toggle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'from ${AppFormatters.formatCurrency(flight.basePrice)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${flight.seatsAvailable} seats left',
                      style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_isExpanded ? 'Hide Fares' : 'View Fares'),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable 3 Fare Families comparison table
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppConstants.darkSurface : AppConstants.lightBg,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: flight.fares
                          .map((fare) => Expanded(child: _buildFareCard(context, fare)))
                          .toList(),
                    )
                  : Column(
                      children: flight.fares
                          .map((fare) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildFareCard(context, fare),
                              ))
                          .toList(),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildFareCard(BuildContext context, FareOption fare) {
    final bool isSelected = widget.selectedFare?.type == fare.type;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color badgeBg = fare.type == FareFamilyType.business
        ? AppConstants.primaryNavy
        : (fare.type == FareFamilyType.flex
            ? AppConstants.saffron
            : const Color(0xFF6B7280));

    return Card(
      elevation: isSelected ? 4 : 0,
      color: isDark ? AppConstants.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppConstants.primaryNavy : AppConstants.borderLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                fare.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Price
            Text(
              AppFormatters.formatCurrency(fare.price),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const Text(
              'per passenger (taxes incl.)',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Allowances & Rules
            _buildBenefit(Icons.backpack_outlined, 'Cabin: ${fare.cabinBaggage}'),
            _buildBenefit(Icons.luggage_outlined, 'Check-in: ${fare.checkInBaggage}'),
            _buildBenefit(Icons.event_seat_outlined, 'Seat: ${fare.seatSelection}'),
            _buildBenefit(Icons.restaurant_outlined, 'Meal: ${fare.meal}'),
            _buildBenefit(
              Icons.change_circle_outlined,
              fare.changeFee == 0 ? 'Free date change' : 'Change fee: ₹${fare.changeFee.toInt()}',
            ),
            _buildBenefit(
              Icons.cancel_outlined,
              'Cancel fee: ₹${fare.cancellationFee.toInt()}',
            ),

            const SizedBox(height: 14),

            // Select Button
            SizedBox(
              width: double.infinity,
              child: isSelected
                  ? ElevatedButton.icon(
                      onPressed: () => widget.onSelectFare(fare),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Selected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.accentGreen,
                        foregroundColor: Colors.white,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => widget.onSelectFare(fare),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryNavy,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Select Fare'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppConstants.primaryNavy),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

