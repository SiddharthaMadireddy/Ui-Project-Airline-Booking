import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/booking.dart';
import 'app_logo.dart';

/// E-Ticket confirmation view with CustomPainter pseudo-QR pattern and share/download actions
class ETicketView extends StatelessWidget {
  final Booking booking;

  const ETicketView({super.key, required this.booking});

  String _generatePlainTextItinerary() {
    final buffer = StringBuffer();
    buffer.writeln('====================================');
    buffer.writeln('  INDIAN AIRLINES - ELECTRONIC TICKET');
    buffer.writeln('  Booking Reference (PNR): ${booking.pnr}');
    buffer.writeln('====================================');
    buffer.writeln('Status: ${booking.status.name.toUpperCase()}');
    buffer.writeln('Booked Date: ${AppFormatters.formatDate(booking.bookingDate)}');
    buffer.writeln('');
    buffer.writeln('FLIGHT DETAILS:');
    buffer.writeln('Flight: ${booking.flight.flightNumber} (${booking.flight.aircraft})');
    buffer.writeln('From: ${booking.flight.origin.displayName}');
    buffer.writeln('To: ${booking.flight.destination.displayName}');
    buffer.writeln('Departure: ${AppFormatters.formatDate(booking.flight.departureTime)} at ${AppFormatters.formatTime(booking.flight.departureTime)}');
    buffer.writeln('Arrival: ${AppFormatters.formatDate(booking.flight.arrivalTime)} at ${AppFormatters.formatTime(booking.flight.arrivalTime)}');
    buffer.writeln('Cabin Class: ${booking.travelClass} (${booking.fareFamily})');
    buffer.writeln('');
    buffer.writeln('PASSENGERS:');
    for (int i = 0; i < booking.passengers.length; i++) {
      final p = booking.passengers[i];
      buffer.writeln('${i + 1}. ${p.fullName} | Seat: ${p.seatNumber ?? 'Unassigned'} | Meal: ${p.mealPreference ?? 'Standard'}');
    }
    buffer.writeln('');
    buffer.writeln('PAYMENT SUMMARY:');
    buffer.writeln('Total Paid: ${AppFormatters.formatCurrency(booking.pricing.grandTotal)} via ${booking.paymentMethod}');
    buffer.writeln('====================================');
    buffer.writeln('DEMO PROJECT: No real flight or payment.');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Navy Header
          Container(
            color: AppConstants.primaryNavy,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppLogo(size: 28, variant: LogoVariant.whiteOnDark),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'BOOKING REFERENCE',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      booking.pnr,
                      style: const TextStyle(
                        color: AppConstants.saffron,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Flight & Passengers Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route and Timings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.flight.origin.code,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppConstants.primaryNavy,
                          ),
                        ),
                        Text(
                          booking.flight.origin.city,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          AppFormatters.formatTime(booking.flight.departureTime),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          AppFormatters.formatDateShort(booking.flight.departureTime),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.flight, color: AppConstants.saffron, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          booking.flight.flightNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          AppFormatters.formatDuration(booking.flight.durationMinutes),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          booking.flight.destination.code,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppConstants.primaryNavy,
                          ),
                        ),
                        Text(
                          booking.flight.destination.city,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          AppFormatters.formatTime(booking.flight.arrivalTime),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          AppFormatters.formatDateShort(booking.flight.arrivalTime),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Passenger List & Pseudo-QR
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PASSENGERS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...booking.passengers.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: AppConstants.primaryNavy),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${p.fullName} (${p.seatNumber ?? 'Seat auto-assigned'})',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Paid: ${AppFormatters.formatCurrency(booking.pricing.grandTotal)} (${booking.paymentMethod})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // CustomPainter Pseudo-QR Pattern
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomPaint(
                            size: const Size(90, 90),
                            painter: _QrCodePainter(booking.pnr),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Scan at Kiosk',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Action Buttons: Download Itinerary & Share
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatePlainTextItinerary()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Itinerary copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Electronic Ticket Itinerary'),
                            content: SingleChildScrollView(
                              child: SelectableText(
                                _generatePlainTextItinerary(),
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _generatePlainTextItinerary()));
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Itinerary copied to clipboard!')),
                                  );
                                },
                                child: const Text('Copy All Text'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download Ticket'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter generating a 2D matrix pseudo-QR code pattern
class _QrCodePainter extends CustomPainter {
  final String seed;
  _QrCodePainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final rng = Random(seed.hashCode);
    const int gridSize = 15;
    final double cellSize = size.width / gridSize;

    // Corner Finder Patterns
    _drawFinder(canvas, 0, 0, cellSize, paint);
    _drawFinder(canvas, (gridSize - 5) * cellSize, 0, cellSize, paint);
    _drawFinder(canvas, 0, (gridSize - 5) * cellSize, cellSize, paint);

    // Matrix pseudo modules
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        // Skip finder pattern zones
        if ((r < 5 && c < 5) || (r < 5 && c >= gridSize - 5) || (r >= gridSize - 5 && c < 5)) {
          continue;
        }
        if (rng.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize * 0.9, cellSize * 0.9),
            paint,
          );
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, double x, double y, double cellSize, Paint paint) {
    final outer = cellSize * 5;
    canvas.drawRect(Rect.fromLTWH(x, y, outer, outer), paint);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + cellSize, y + cellSize, outer - cellSize * 2, outer - cellSize * 2), whitePaint);
    canvas.drawRect(Rect.fromLTWH(x + cellSize * 1.5, y + cellSize * 1.5, cellSize * 2, cellSize * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

