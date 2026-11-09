import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/booking.dart';
import 'app_logo.dart';

/// Boarding pass widget featuring CustomPainter barcode and airport departure gate details
class BoardingPassWidget extends StatelessWidget {
  final BoardingPassData pass;

  const BoardingPassWidget({super.key, required this.pass});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppConstants.borderLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header Banner
              Container(
                color: AppConstants.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppLogo(
                      size: 26,
                      variant: LogoVariant.whiteOnDark,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.saffron,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BOARDING PASS',
                        style: TextStyle(
                          color: AppConstants.primaryNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Passenger & Flight Info
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Route Code Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pass.originCode,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppConstants.primaryNavy,
                              ),
                            ),
                            const Text(
                              'ORIGIN',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Icon(Icons.flight_takeoff, color: AppConstants.saffron, size: 28),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              pass.destinationCode,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppConstants.primaryNavy,
                              ),
                            ),
                            const Text(
                              'DESTINATION',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Passenger Details Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('PASSENGER NAME', pass.passengerName),
                        _buildInfoColumn('PNR CODE', pass.pnr),
                        _buildInfoColumn('FLIGHT', pass.flightNumber),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('SEAT', pass.seat, isHighlighted: true),
                        _buildInfoColumn('GATE', pass.gate, isHighlighted: true),
                        _buildInfoColumn('BOARDING', AppFormatters.formatTime(pass.boardingTime), isHighlighted: true),
                        _buildInfoColumn('GROUP', pass.boardingGroup),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // CustomPainter Barcode
                    CustomPaint(
                      size: const Size(double.infinity, 50),
                      painter: _BarcodePainter(pass.pnr + pass.flightNumber),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${pass.pnr}-${pass.flightNumber}-${pass.seat}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        letterSpacing: 2,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Notice Banner
              Container(
                width: double.infinity,
                color: AppConstants.lightBg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Gate closes 20 minutes before departure',
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppConstants.primaryNavy : Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// CustomPainter drawing a realistic Code-128 style barcode
class _BarcodePainter extends CustomPainter {
  final String data;
  _BarcodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final rng = Random(data.hashCode);
    double x = 10;
    while (x < size.width - 10) {
      final barWidth = (rng.nextInt(3) + 1.0) * 1.5;
      final gap = (rng.nextInt(3) + 1.0) * 1.5;
      canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

