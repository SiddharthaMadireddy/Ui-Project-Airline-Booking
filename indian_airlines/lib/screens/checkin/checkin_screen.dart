import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/responsive.dart';
import '../../models/booking.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/boarding_pass.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// Web check-in screen with 48h-2h departure window enforcement and boarding pass generation
class CheckinScreen extends StatefulWidget {
  final Map<String, dynamic>? initialLookup;
  const CheckinScreen({super.key, this.initialLookup});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final _pnrController = TextEditingController();
  final _lastNameController = TextEditingController();
  Booking? _activeBooking;
  bool _isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLookup != null) {
        final pnr = widget.initialLookup!['pnr'] as String?;
        final last = widget.initialLookup!['lastName'] as String?;
        if (pnr != null && pnr.isNotEmpty) {
          _pnrController.text = pnr;
          _lastNameController.text = last ?? '';
          _lookupBooking();
        }
      }
    });
  }

  @override
  void dispose() {
    _pnrController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _lookupBooking() {
    final trips = context.read<TripsProvider>();
    final match = trips.lookupByPnrAndLastName(
      _pnrController.text.trim(),
      _lastNameController.text.trim(),
    );

    if (match != null) {
      setState(() {
        _activeBooking = match;
        _isCheckedIn = match.isCheckedIn;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active booking found matching PNR and Last Name'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNav(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Banner
            Container(
              color: AppConstants.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              width: double.infinity,
              child: ResponsiveContainer(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Web Check-in & Digital Boarding Pass',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Available 48 hours to 2 hours prior to scheduled departure time',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ResponsiveContainer(
              child: _activeBooking != null
                  ? _buildCheckinContent(context, _activeBooking!)
                  : _buildLookupForm(context),
            ),

            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  // --- 1. Lookup Form ---
  Widget _buildLookupForm(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Retrieve Booking to Check-in',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter the 6-character booking reference printed on your e-ticket itinerary receipt.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pnrController,
                    decoration: const InputDecoration(
                      labelText: 'Booking Reference / PNR (e.g. IA7K9P)',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Passenger Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _lookupBooking,
                  child: const Text('Retrieve Booking'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Quick Seeded Demo Booking Button
            Row(
              children: [
                const Icon(Icons.bolt, color: AppConstants.saffron, size: 18),
                const SizedBox(width: 6),
                const Text('Viva / Evaluator Demo Shortcut: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () {
                    _pnrController.text = 'IA7K9P';
                    _lastNameController.text = 'Sharma';
                    _lookupBooking();
                  },
                  child: const Text(
                    'Load Pre-seeded Check-in Booking: IA7K9P (Departure in 18 hrs)',
                    style: TextStyle(
                      color: AppConstants.primaryNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Check-in Flow and Boarding Pass View ---
  Widget _buildCheckinContent(BuildContext context, Booking booking) {
    final bool isEligible = TripsProvider.isEligibleForCheckIn(booking.flight.departureTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _activeBooking = null),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Check-in Another Booking'),
            ),
            Text(
              'PNR: ${booking.pnr}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Check-in Eligibility Window Warning / Status
        if (!isEligible && !booking.isCheckedIn)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade400),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Web Check-in is not currently open for flight ${booking.flight.flightNumber}. It opens strictly 48 hours before departure (${AppFormatters.formatDate(booking.flight.departureTime.subtract(const Duration(hours: 48)))}).',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        // If Already Checked In: Display Boarding Passes
        if (_isCheckedIn || booking.isCheckedIn) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppConstants.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConstants.accentGreen),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppConstants.accentGreen),
                SizedBox(width: 10),
                Text(
                  'Web Check-in Completed. Present this boarding pass at airport security.',
                  style: TextStyle(color: AppConstants.accentGreen, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...booking.boardingPasses.map(
            (pass) => Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: BoardingPassWidget(pass: pass),
            ),
          ),
        ] else if (isEligible) ...[
          // Eligible for check-in: Passenger Seat Confirmation
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Confirm Passenger Details & Seats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Flight ${booking.flight.flightNumber} • Departs ${AppFormatters.formatDate(booking.flight.departureTime)} at ${AppFormatters.formatTime(booking.flight.departureTime)}'),
                  const SizedBox(height: 16),
                  const Divider(),
                  ...booking.passengers.map(
                    (p) => ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppConstants.primaryNavy,
                        child: Icon(Icons.person, color: Colors.white, size: 18),
                      ),
                      title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Assigned Seat: ${p.seatNumber ?? '12A'} • Baggage Tagged'),
                      trailing: const Icon(Icons.check_circle, color: AppConstants.accentGreen),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final trips = context.read<TripsProvider>();
                        final updated = await trips.checkIn(
                          pnr: booking.pnr,
                          passengerSeats: {
                            for (final p in booking.passengers)
                              p.id: p.seatNumber ?? '14B',
                          },
                        );
                        setState(() {
                          _activeBooking = updated;
                          _isCheckedIn = true;
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Generate Boarding Passes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

