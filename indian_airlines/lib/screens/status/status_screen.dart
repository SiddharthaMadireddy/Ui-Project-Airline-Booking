import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/responsive.dart';
import '../../data/airports.dart';
import '../../data/flight_generator.dart';
import '../../models/flight.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// Flight status screen with live timeline stepper, gate, and baggage carousel info
class StatusScreen extends StatefulWidget {
  final String? initialFlightNumber;
  const StatusScreen({super.key, this.initialFlightNumber});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final _flightNumberController = TextEditingController(text: 'IA-204');
  Flight? _trackedFlight;

  @override
  void initState() {
    super.initState();
    if (widget.initialFlightNumber != null && widget.initialFlightNumber!.isNotEmpty) {
      _flightNumberController.text = widget.initialFlightNumber!;
    }
    _trackFlight();
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    super.dispose();
  }

  void _trackFlight() {
    // Generate deterministic demo flight
    final bom = AirportData.findByCode('BOM')!;
    final del = AirportData.findByCode('DEL')!;
    final flights = FlightGenerator.generate(
      origin: bom,
      destination: del,
      date: DateTime.now(),
    );
    setState(() {
      _trackedFlight = flights.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNav(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              color: AppConstants.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              width: double.infinity,
              child: ResponsiveContainer(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Flight Status & Route Tracker',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Real-time updates on scheduled departures, arrivals, terminal gates and baggage carousels',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ResponsiveContainer(
              child: Column(
                children: [
                  // Search Form Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _flightNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Flight Number (e.g. IA-204)',
                                prefixIcon: Icon(Icons.flight),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _trackFlight,
                            child: const Text('Track Flight'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_trackedFlight != null) _buildStatusCard(context, _trackedFlight!),
                ],
              ),
            ),

            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Flight flight) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      flight.flightNumber,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppConstants.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      flight.aircraft,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.accentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppConstants.accentGreen),
                  ),
                  child: const Text(
                    'ON TIME',
                    style: TextStyle(
                      color: AppConstants.accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // Route & Timings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.origin.code,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    Text(flight.origin.city, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Departure: ${AppFormatters.formatTime(flight.departureTime)}'),
                    const Text('Terminal T2 • Gate 14', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Icon(Icons.flight_takeoff, color: AppConstants.saffron, size: 36),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flight.destination.code,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    Text(flight.destination.city, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Arrival: ${AppFormatters.formatTime(flight.arrivalTime)}'),
                    const Text('Terminal T3 • Carousel 4', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Flight Progress Timeline Stepper
            const Text(
              'Flight Milestone Progress',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // 5 Milestone Steps
            Row(
              children: [
                _buildTimelinePoint('Scheduled', isCompleted: true),
                _buildTimelineLine(isCompleted: true),
                _buildTimelinePoint('Boarding', isCompleted: true),
                _buildTimelineLine(isCompleted: true),
                _buildTimelinePoint('Departed', isCompleted: true),
                _buildTimelineLine(isCompleted: false),
                _buildTimelinePoint('In-Air', isCompleted: false, isCurrent: true),
                _buildTimelineLine(isCompleted: false),
                _buildTimelinePoint('Landed', isCompleted: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelinePoint(String label, {bool isCompleted = false, bool isCurrent = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isCompleted
              ? AppConstants.accentGreen
              : (isCurrent ? AppConstants.saffron : Colors.grey.shade300),
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : (isCurrent
                  ? const Icon(Icons.flight, size: 14, color: AppConstants.primaryNavy)
                  : const SizedBox.shrink()),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? AppConstants.primaryNavy : (isCompleted ? AppConstants.accentGreen : Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine({bool isCompleted = false}) {
    return Expanded(
      child: Container(
        height: 3,
        color: isCompleted ? AppConstants.accentGreen : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}

