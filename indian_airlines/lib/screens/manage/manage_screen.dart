import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/responsive.dart';
import '../../data/flight_generator.dart';
import '../../models/booking.dart';
import '../../models/flight.dart';
import '../../providers/trips_provider.dart';
import '../../services/refund_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/eticket_view.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// Manage booking screen with lookup, cancellation refund dialog, and rescheduling
class ManageScreen extends StatefulWidget {
  final Map<String, dynamic>? initialLookup;
  const ManageScreen({super.key, this.initialLookup});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen>
    with SingleTickerProviderStateMixin {
  final _pnrController = TextEditingController();
  final _lastNameController = TextEditingController();
  Booking? _selectedBooking;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLookup != null) {
        final pnr = widget.initialLookup!['pnr'] as String?;
        final last = widget.initialLookup!['lastName'] as String?;
        if (pnr != null && pnr.isNotEmpty) {
          _pnrController.text = pnr;
          _lastNameController.text = last ?? '';
          _searchBooking(pnr, last ?? '');
        }
      }
    });
  }

  @override
  void dispose() {
    _pnrController.dispose();
    _lastNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _searchBooking(String pnr, String last) {
    final trips = context.read<TripsProvider>();
    final match = trips.lookupByPnrAndLastName(pnr, last);
    if (match != null) {
      setState(() {
        _selectedBooking = match;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No booking found matching PNR and Last Name'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();

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
                      'Manage Booking & My Trips',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cancel tickets with instant refund calculation, reschedule flights, or download e-tickets',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ResponsiveContainer(
              child: _selectedBooking != null
                  ? _buildBookingDetailView(context, _selectedBooking!)
                  : _buildTabsAndLookupView(context, trips),
            ),

            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsAndLookupView(BuildContext context, TripsProvider trips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PNR Lookup Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Find a Specific Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pnrController,
                        decoration: const InputDecoration(labelText: '6-character PNR (e.g. IA7K9P)'),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Passenger Last Name'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _searchBooking(_pnrController.text, _lastNameController.text),
                      child: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Quick Viva Demo: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    InkWell(
                      onTap: () {
                        _pnrController.text = 'IA7K9P';
                        _lastNameController.text = 'Sharma';
                        _searchBooking('IA7K9P', 'Sharma');
                      },
                      child: const Text(
                        'IA7K9P (Sharma - Eligible Check-in)',
                        style: TextStyle(fontSize: 12, color: AppConstants.saffron, decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        _pnrController.text = 'IA3X2M';
                        _lastNameController.text = 'Verma';
                        _searchBooking('IA3X2M', 'Verma');
                      },
                      child: const Text(
                        'IA3X2M (Verma - Business)',
                        style: TextStyle(fontSize: 12, color: AppConstants.saffron, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Tabs: Upcoming | Completed | Cancelled
        TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.saffron,
          labelColor: AppConstants.primaryNavy,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'Upcoming (${trips.upcomingBookings.length})'),
            Tab(text: 'Completed (${trips.completedBookings.length})'),
            Tab(text: 'Cancelled (${trips.cancelledBookings.length})'),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 380,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(trips.upcomingBookings),
              _buildBookingList(trips.completedBookings),
              _buildBookingList(trips.cancelledBookings),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingList(List<Booking> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No bookings in this category', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final booking = list[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              '${booking.flight.origin.city} (${booking.flight.origin.code}) → ${booking.flight.destination.city} (${booking.flight.destination.code})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'PNR: ${booking.pnr} • ${AppFormatters.formatDateShort(booking.flight.departureTime)} • ${booking.passengers.length} Pax',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusChip(booking.status),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedBooking = booking;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color bg;
    Color text;
    switch (status) {
      case BookingStatus.confirmed:
        bg = AppConstants.accentGreen.withValues(alpha: 0.15);
        text = AppConstants.accentGreen;
        break;
      case BookingStatus.cancelled:
        bg = Colors.red.withValues(alpha: 0.15);
        text = Colors.red;
        break;
      case BookingStatus.completed:
        bg = Colors.blue.withValues(alpha: 0.15);
        text = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  // --- Detailed Booking View (Manage / Cancel / Reschedule) ---
  Widget _buildBookingDetailView(BuildContext context, Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _selectedBooking = null),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to All Bookings'),
            ),
            _buildStatusChip(booking.status),
          ],
        ),
        const SizedBox(height: 16),

        // E-Ticket View
        ETicketView(booking: booking),

        const SizedBox(height: 24),

        // Actions: Reschedule & Cancel Ticket (if confirmed)
        if (booking.status == BookingStatus.confirmed)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showRescheduleDialog(context, booking),
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Reschedule Flight'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showCancellationDialog(context, booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Booking & Refund'),
              ),
            ],
          ),
      ],
    );
  }

  // --- Cancellation & Instant Refund Calculation Dialog ---
  void _showCancellationDialog(BuildContext context, Booking booking) {
    final result = RefundService.calculateCancellationRefund(booking);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Flight Cancellation & Refund'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PNR: ${booking.pnr} (${booking.flight.origin.code} → ${booking.flight.destination.code})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                result.policyExplanation,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildDialogPriceRow('Base Fare Refund:', result.baseFareRefund),
              _buildDialogPriceRow('Taxes & Surcharges Refund:', result.taxesRefund),
              _buildDialogPriceRow('Add-ons Refund:', result.addOnsRefund),
              _buildDialogPriceRow('Cancellation Fee:', -result.cancellationFee, isFee: true),
              const Divider(),
              _buildDialogPriceRow('Net Refund Payable:', result.totalRefund, isTotal: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Ticket'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final trips = context.read<TripsProvider>();
              await trips.cancelBooking(booking.pnr);
              if (mounted) {
                setState(() {
                  _selectedBooking = null;
                });
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Booking ${booking.pnr} cancelled. Refund of ${AppFormatters.formatCurrency(result.totalRefund)} processed to original payment method.'),
                    backgroundColor: AppConstants.accentGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }

  // --- Reschedule Dialog ---
  void _showRescheduleDialog(BuildContext context, Booking booking) {
    DateTime selectedNewDate = booking.flight.departureTime.add(const Duration(days: 2));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final newFlights = FlightGenerator.generate(
            origin: booking.flight.origin,
            destination: booking.flight.destination,
            date: selectedNewDate,
          );
          Flight? chosenFlight = newFlights.isNotEmpty ? newFlights.first : null;

          return AlertDialog(
            title: const Text('Reschedule Journey Date'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Route: ${booking.flight.origin.displayName} → ${booking.flight.destination.displayName}'),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Choose New Departure Date'),
                    subtitle: Text(AppFormatters.formatDate(selectedNewDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedNewDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 180)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedNewDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Available Flights on selected date:'),
                  const SizedBox(height: 6),
                  if (chosenFlight != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.flight),
                        title: Text('${chosenFlight.flightNumber} • ${AppFormatters.formatTime(chosenFlight.departureTime)}'),
                        subtitle: Text('Fare: ${AppFormatters.formatCurrency(chosenFlight.basePrice)}'),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (chosenFlight != null) {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    final trips = context.read<TripsProvider>();
                    await trips.rescheduleBooking(
                      pnr: booking.pnr,
                      newFlight: chosenFlight,
                      newFare: chosenFlight.fares.first,
                    );
                    if (mounted) {
                      setState(() {
                        _selectedBooking = null;
                      });
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Flight rescheduled successfully!'), backgroundColor: AppConstants.accentGreen),
                      );
                    }
                  }
                },
                child: const Text('Confirm Reschedule'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogPriceRow(String label, double amount, {bool isFee = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          Text(
            AppFormatters.formatCurrency(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFee ? Colors.red : (isTotal ? AppConstants.primaryNavy : null),
            ),
          ),
        ],
      ),
    );
  }
}
