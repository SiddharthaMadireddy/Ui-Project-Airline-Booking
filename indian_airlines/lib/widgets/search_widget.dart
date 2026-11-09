import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/responsive.dart';
import '../data/airports.dart';
import '../models/airport.dart';
import '../models/search_query.dart';
import '../providers/search_provider.dart';

/// Flight search card with 4 tabs: Book Flight, Manage Booking, Check-in, Flight Status
class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _swapAnimController;

  // Manage booking controllers
  final _managePnrController = TextEditingController();
  final _manageLastNameController = TextEditingController();

  // Check-in controllers
  final _checkinPnrController = TextEditingController();
  final _checkinLastNameController = TextEditingController();

  // Flight status controllers
  final _statusFlightNumberController = TextEditingController(text: 'IA-204');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _swapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _swapAnimController.dispose();
    _managePnrController.dispose();
    _manageLastNameController.dispose();
    _checkinPnrController.dispose();
    _checkinLastNameController.dispose();
    _statusFlightNumberController.dispose();
    super.dispose();
  }

  void _triggerSwapAnimation() {
    if (_swapAnimController.isCompleted) {
      _swapAnimController.reverse();
    } else {
      _swapAnimController.forward();
    }
    context.read<SearchProvider>().swapOriginDestination();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top 4 Main Tabs
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkSurface : AppConstants.lightBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: !isDesktop,
              tabAlignment: isDesktop ? TabAlignment.fill : TabAlignment.start,
              indicatorColor: AppConstants.saffron,
              indicatorWeight: 3,
              labelColor: isDark ? AppConstants.saffron : AppConstants.primaryNavy,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(icon: Icon(Icons.flight_takeoff, size: 18), text: 'Book Flight'),
                Tab(icon: Icon(Icons.edit_calendar, size: 18), text: 'Manage Booking'),
                Tab(icon: Icon(Icons.qr_code_scanner, size: 18), text: 'Check-in'),
                Tab(icon: Icon(Icons.access_time_filled, size: 18), text: 'Flight Status'),
              ],
            ),
          ),

          // Tab Contents
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: [
                _buildBookFlightTab(context),
                _buildManageBookingTab(context),
                _buildCheckinTab(context),
                _buildFlightStatusTab(context),
              ][_tabController.index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookFlightTab(BuildContext context) {
    final search = context.watch<SearchProvider>();
    final query = search.query;
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Trip Type Segmented Control
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<TripType>(
                segments: const [
                  ButtonSegment(value: TripType.oneWay, label: Text('One-way')),
                  ButtonSegment(value: TripType.roundTrip, label: Text('Round-trip')),
                  ButtonSegment(value: TripType.multiCity, label: Text('Multi-city')),
                ],
                selected: {query.tripType},
                onSelectionChanged: (set) => search.setTripType(set.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)),
                ),
              ),
            ),
            if (isDesktop)
              Text(
                '${query.totalPassengers} Passenger(s) • ${query.travelClass}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. Origin & Destination with Animated Swap
        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildAirportAutocomplete(isOrigin: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_swapAnimController),
                  child: IconButton.filledTonal(
                    onPressed: _triggerSwapAnimation,
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Swap Origin and Destination',
                  ),
                ),
              ),
              Expanded(child: _buildAirportAutocomplete(isOrigin: false)),
              const SizedBox(width: 16),
              // Dates
              Expanded(child: _buildDatePicker(context, isDeparture: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildDatePicker(context, isDeparture: false)),
            ],
          )
        else ...[
          _buildAirportAutocomplete(isOrigin: true),
          Align(
            alignment: Alignment.centerRight,
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(_swapAnimController),
              child: IconButton(
                onPressed: _triggerSwapAnimation,
                icon: const Icon(Icons.swap_vert, color: AppConstants.primaryNavy),
              ),
            ),
          ),
          _buildAirportAutocomplete(isOrigin: false),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDatePicker(context, isDeparture: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildDatePicker(context, isDeparture: false)),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // 3. Passengers & Class Selector & Promo Code
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showPassengerDialog(context),
              icon: const Icon(Icons.person_outline, size: 18),
              label: Text('${query.totalPassengers} Pax • ${query.travelClass}'),
            ),
            SizedBox(
              width: 170,
              child: TextFormField(
                initialValue: query.promoCode,
                decoration: const InputDecoration(
                  hintText: 'Promo code',
                  prefixIcon: Icon(Icons.local_offer_outlined, size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (val) => search.setPromoCode(val.trim()),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 4. Special Fare Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Special Fares:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            ...['Regular', 'Student', 'Senior Citizen', 'Armed Forces'].map((type) {
              final isSelected = query.fareType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                selectedColor: AppConstants.saffron.withValues(alpha: 0.25),
                onSelected: (_) => search.setFareType(type),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppConstants.primaryNavy : null,
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: 20),

        // 5. Submit Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () async {
              final err = search.validateSearch();
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              // Navigate to search screen
              Navigator.pushNamed(context, '/search');
              await search.searchFlights();
            },
            icon: const Icon(Icons.search, size: 20),
            label: const Text('Search Flights', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildAirportAutocomplete({required bool isOrigin}) {
    final search = context.watch<SearchProvider>();
    final current = isOrigin ? search.query.origin : search.query.destination;

    return Autocomplete<Airport>(
      initialValue: TextEditingValue(text: current?.shortName ?? ''),
      displayStringForOption: (Airport opt) => opt.shortName,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return AirportData.airports.take(8);
        }
        return AirportData.search(textEditingValue.text);
      },
      onSelected: (Airport selection) {
        if (isOrigin) {
          search.setOrigin(selection);
        } else {
          search.setDestination(selection);
        }
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: isOrigin ? 'From (Origin)' : 'To (Destination)',
            prefixIcon: Icon(
              isOrigin ? Icons.flight_takeoff : Icons.flight_land,
              color: AppConstants.primaryNavy,
              size: 20,
            ),
            hintText: 'City or 3-letter code (e.g. DEL)',
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () => controller.clear(),
                  )
                : null,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280, maxWidth: 360),
              child: ListView.separated(
                padding: const EdgeInsets.all(4),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final airport = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        airport.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryNavy,
                        ),
                      ),
                    ),
                    title: Text(airport.city, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${airport.name} • ${airport.country}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => onSelected(airport),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(BuildContext context, {required bool isDeparture}) {
    final search = context.watch<SearchProvider>();
    final query = search.query;
    final isRoundTrip = query.tripType == TripType.roundTrip;
    final date = isDeparture ? query.departureDate : query.returnDate;

    final bool enabled = isDeparture || isRoundTrip;

    return InkWell(
      onTap: enabled
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? query.departureDate.add(const Duration(days: 3)),
                firstDate: isDeparture
                    ? DateTime.now()
                    : query.departureDate,
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                if (isDeparture) {
                  search.setDepartureDate(picked);
                } else {
                  search.setReturnDate(picked);
                }
              }
            }
          : null,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isDeparture ? 'Departure Date' : 'Return Date',
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
          enabled: enabled,
        ),
        child: Text(
          enabled && date != null
              ? AppFormatters.formatDateShort(date)
              : (isRoundTrip ? 'Select Date' : 'One-way only'),
          style: TextStyle(
            color: enabled ? null : Colors.black38,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showPassengerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer<SearchProvider>(
          builder: (context, search, _) {
            final q = search.query;
            return AlertDialog(
              title: const Text('Passengers & Cabin Class'),
              content: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStepperRow(
                      'Adults (12+ yrs)',
                      q.adults,
                      onDec: q.adults > 1
                          ? () => search.updatePassengers(
                                adults: q.adults - 1,
                                children: q.children,
                                infants: q.infants,
                              )
                          : null,
                      onInc: search.canAddAdult()
                          ? () => search.updatePassengers(
                                adults: q.adults + 1,
                                children: q.children,
                                infants: q.infants,
                              )
                          : null,
                    ),
                    const Divider(),
                    _buildStepperRow(
                      'Children (2-11 yrs)',
                      q.children,
                      onDec: q.children > 0
                          ? () => search.updatePassengers(
                                adults: q.adults,
                                children: q.children - 1,
                                infants: q.infants,
                              )
                          : null,
                      onInc: search.canAddChild()
                          ? () => search.updatePassengers(
                                adults: q.adults,
                                children: q.children + 1,
                                infants: q.infants,
                              )
                          : null,
                    ),
                    const Divider(),
                    _buildStepperRow(
                      'Infants (under 2 yrs)',
                      q.infants,
                      subtitle: 'Infants cannot exceed adults',
                      onDec: q.infants > 0
                          ? () => search.updatePassengers(
                                adults: q.adults,
                                children: q.children,
                                infants: q.infants - 1,
                              )
                          : null,
                      onInc: search.canAddInfant()
                          ? () => search.updatePassengers(
                                adults: q.adults,
                                children: q.children,
                                infants: q.infants + 1,
                              )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: q.travelClass,
                      decoration: const InputDecoration(labelText: 'Cabin Class'),
                      items: const [
                        DropdownMenuItem(value: 'Economy', child: Text('Economy')),
                        DropdownMenuItem(
                          value: 'Premium Economy',
                          child: Text('Premium Economy'),
                        ),
                        DropdownMenuItem(value: 'Business', child: Text('Business')),
                      ],
                      onChanged: (val) {
                        if (val != null) search.setTravelClass(val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStepperRow(
    String title,
    int count, {
    String? subtitle,
    VoidCallback? onDec,
    VoidCallback? onInc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              if (subtitle != null)
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onDec,
                iconSize: 20,
              ),
              Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onInc,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Tab 2: Manage Booking ---
  Widget _buildManageBookingTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Retrieve Your Booking',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'View itinerary, cancel with instant refund, reschedule, or select seats.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _managePnrController,
                decoration: const InputDecoration(
                  labelText: 'Booking Reference / PNR (e.g. IA7K9P)',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _manageLastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name (as on ticket)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                _managePnrController.text = 'IA7K9P';
                _manageLastNameController.text = 'Sharma';
              },
              icon: const Icon(Icons.bolt, size: 16, color: AppConstants.saffron),
              label: const Text('Try Demo PNR: IA7K9P (Sharma)'),
            ),
            ElevatedButton(
              onPressed: () {
                final pnr = _managePnrController.text.trim();
                final last = _manageLastNameController.text.trim();
                if (pnr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter PNR code')),
                  );
                  return;
                }
                Navigator.pushNamed(context, '/manage', arguments: {'pnr': pnr, 'lastName': last});
              },
              child: const Text('Retrieve Booking'),
            ),
          ],
        ),
      ],
    );
  }

  // --- Tab 3: Check-in ---
  Widget _buildCheckinTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Web Check-in (Opens 48h to 2h before departure)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Confirm seats, get boarding passes and skip long check-in queues.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _checkinPnrController,
                decoration: const InputDecoration(
                  labelText: 'Booking Reference / PNR',
                  prefixIcon: Icon(Icons.airplane_ticket_outlined),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _checkinLastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                _checkinPnrController.text = 'IA7K9P';
                _checkinLastNameController.text = 'Sharma';
              },
              icon: const Icon(Icons.bolt, size: 16, color: AppConstants.saffron),
              label: const Text('Try Demo Check-in PNR: IA7K9P'),
            ),
            ElevatedButton(
              onPressed: () {
                final pnr = _checkinPnrController.text.trim();
                final last = _checkinLastNameController.text.trim();
                if (pnr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter PNR code')),
                  );
                  return;
                }
                Navigator.pushNamed(context, '/checkin', arguments: {'pnr': pnr, 'lastName': last});
              },
              child: const Text('Begin Web Check-in'),
            ),
          ],
        ),
      ],
    );
  }

  // --- Tab 4: Flight Status ---
  Widget _buildFlightStatusTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Flight Status Tracker',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Track real-time departures, arrivals, terminal gates and baggage carousels.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _statusFlightNumberController,
                decoration: const InputDecoration(
                  labelText: 'Flight Number (e.g. IA-204)',
                  prefixIcon: Icon(Icons.flight),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                final flightNo = _statusFlightNumberController.text.trim();
                Navigator.pushNamed(context, '/status', arguments: flightNo);
              },
              child: const Text('Check Status'),
            ),
          ],
        ),
      ],
    );
  }
}
