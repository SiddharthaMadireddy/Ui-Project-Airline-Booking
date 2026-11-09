import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/responsive.dart';
import '../../models/search_query.dart';
import '../../providers/booking_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/flight_card.dart';
import '../../widgets/footer.dart';
import '../../widgets/search_widget.dart';
import '../../widgets/top_nav.dart';

/// Flight search results screen with 7-day strip, responsive filters, and round-trip leg selection
class SearchScreen extends StatefulWidget {
  final String? query;
  const SearchScreen({super.key, this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isEditSearchOpen = false;
  bool _selectingReturnLeg = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final search = context.read<SearchProvider>();
      if (search.filteredOutboundFlights.isEmpty && !search.isSearching) {
        search.searchFlights();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchProvider>();
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: const TopNav(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary Header with "Edit Search" Collapse
            _buildSearchSummaryBar(context, search),

            // Collapsible Search Widget
            if (_isEditSearchOpen)
              Container(
                color: AppConstants.lightBg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ResponsiveContainer(
                  child: const SearchWidget(),
                ),
              ),

            const SizedBox(height: 12),

            // 7-Day Lowest Fare Strip
            _build7DayStrip(context, search),

            const SizedBox(height: 16),

            // Main Content: Filters (Sidebar or Button) + Flight List
            ResponsiveContainer(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Filter Sidebar (Desktop)
                        SizedBox(
                          width: 280,
                          child: _buildFilterCard(context, search),
                        ),
                        const SizedBox(width: 24),
                        // Flight List
                        Expanded(child: _buildFlightList(context, search)),
                      ],
                    )
                  : Column(
                      children: [
                        // Mobile Filter & Sort Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showMobileFilterBottomSheet(context, search),
                              icon: const Icon(Icons.tune, size: 18),
                              label: const Text('Filters & Sorting'),
                            ),
                            Text(
                              '${search.filteredOutboundFlights.length} Flights Found',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFlightList(context, search),
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

  // --- 1. Summary Bar with Edit Search ---
  Widget _buildSearchSummaryBar(BuildContext context, SearchProvider search) {
    final q = search.query;
    final isRoundTrip = q.tripType == TripType.roundTrip;

    return Container(
      color: AppConstants.primaryNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${q.origin?.city ?? 'DEL'} (${q.origin?.code ?? 'DEL'})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isRoundTrip ? Icons.sync_alt : Icons.arrow_forward,
                          color: AppConstants.saffron,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${q.destination?.city ?? 'BOM'} (${q.destination?.code ?? 'BOM'})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatters.formatDateShort(q.departureDate)}${isRoundTrip && q.returnDate != null ? ' - ${AppFormatters.formatDateShort(q.returnDate)}' : ''} • ${q.totalPassengers} Pax • ${q.travelClass}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditSearchOpen = !_isEditSearchOpen;
                  });
                },
                icon: Icon(
                  _isEditSearchOpen ? Icons.close : Icons.edit,
                  size: 14,
                ),
                label: Text(_isEditSearchOpen ? 'Close' : 'Modify'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.saffron,
                  foregroundColor: AppConstants.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. 7-Day Lowest Fare Strip ---
  Widget _build7DayStrip(BuildContext context, SearchProvider search) {
    final dailyFares = search.dailyLowestFares;
    if (dailyFares.isEmpty) return const SizedBox.shrink();

    return ResponsiveContainer(
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppConstants.borderLight),
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: dailyFares.entries.map((entry) {
            final date = entry.key;
            final fare = entry.value;
            final bool isSelected = date.year == search.query.departureDate.year &&
                date.month == search.query.departureDate.month &&
                date.day == search.query.departureDate.day;

            return InkWell(
              onTap: () {
                search.setDepartureDate(date);
                search.searchFlights();
              },
              child: Container(
                width: 130,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryNavy.withValues(alpha: 0.08)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppConstants.saffron : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppFormatters.formatDateCompact(date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatCurrency(fare),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppConstants.primaryNavy : AppConstants.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- 3. Filter Card (Sidebar / BottomSheet) ---
  Widget _buildFilterCard(BuildContext context, SearchProvider search) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppConstants.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters & Sort',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => search.resetFilters(),
                  child: const Text('Reset', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const Divider(),

            // Sort By
            const SizedBox(height: 8),
            const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Cheapest'),
                  selected: search.sortBy == 'cheapest',
                  onSelected: (_) => search.setSortBy('cheapest'),
                ),
                ChoiceChip(
                  label: const Text('Fastest'),
                  selected: search.sortBy == 'fastest',
                  onSelected: (_) => search.setSortBy('fastest'),
                ),
                ChoiceChip(
                  label: const Text('Earliest'),
                  selected: search.sortBy == 'earliest',
                  onSelected: (_) => search.setSortBy('earliest'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Stops
            const SizedBox(height: 8),
            const Text('Stops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Non-Stop', style: TextStyle(fontSize: 13)),
              value: search.selectedStops.contains(0),
              onChanged: (_) => search.toggleStop(0),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('1 Stop via Hub', style: TextStyle(fontSize: 13)),
              value: search.selectedStops.contains(1),
              onChanged: (_) => search.toggleStop(1),
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Departure Time
            const SizedBox(height: 8),
            const Text('Departure Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                FilterChip(
                  label: const Text('Early (04-08)', style: TextStyle(fontSize: 11)),
                  selected: search.selectedTimeSlots.contains('early'),
                  onSelected: (_) => search.toggleTimeSlot('early'),
                ),
                FilterChip(
                  label: const Text('Morning (08-12)', style: TextStyle(fontSize: 11)),
                  selected: search.selectedTimeSlots.contains('morning'),
                  onSelected: (_) => search.toggleTimeSlot('morning'),
                ),
                FilterChip(
                  label: const Text('Afternoon (12-18)', style: TextStyle(fontSize: 11)),
                  selected: search.selectedTimeSlots.contains('afternoon'),
                  onSelected: (_) => search.toggleTimeSlot('afternoon'),
                ),
                FilterChip(
                  label: const Text('Night (18-24)', style: TextStyle(fontSize: 11)),
                  selected: search.selectedTimeSlots.contains('night'),
                  onSelected: (_) => search.toggleTimeSlot('night'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Price Range Slider
            const SizedBox(height: 8),
            Text(
              'Max Price: ${AppFormatters.formatCurrency(search.priceRange.end)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            RangeSlider(
              values: search.priceRange,
              min: search.minPrice > 0 ? search.minPrice : 0,
              max: search.maxPrice > search.minPrice ? search.maxPrice : 50000,
              divisions: 20,
              activeColor: AppConstants.primaryNavy,
              onChanged: (vals) => search.setPriceRange(vals),
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileFilterBottomSheet(BuildContext context, SearchProvider search) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _buildFilterCard(context, search),
        ),
      ),
    );
  }

  // --- 4. Flight List with Skeleton and Empty States ---
  Widget _buildFlightList(BuildContext context, SearchProvider search) {
    if (search.isSearching) {
      return _buildSkeletonLoading();
    }

    final isRoundTrip = search.query.tripType == TripType.roundTrip;
    final flights = _selectingReturnLeg
        ? search.filteredReturnFlights
        : search.filteredOutboundFlights;

    if (flights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.flight_takeoff, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Flights Found Matching Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try clearing some filter criteria or adjusting departure date.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => search.resetFilters(),
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Round trip leg header
        if (isRoundTrip)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppConstants.saffron.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConstants.saffron),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectingReturnLeg
                      ? 'Step 2 of 2: Select Return Flight to ${search.query.origin?.city}'
                      : 'Step 1 of 2: Select Outbound Flight to ${search.query.destination?.city}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (_selectingReturnLeg)
                  TextButton(
                    onPressed: () => setState(() => _selectingReturnLeg = false),
                    child: const Text('Change Outbound'),
                  ),
              ],
            ),
          ),

        // Flights List
        ...flights.map((flight) {
          final isSelected = _selectingReturnLeg
              ? search.selectedReturnFlight?.flightNumber == flight.flightNumber
              : search.selectedOutboundFlight?.flightNumber == flight.flightNumber;

          return FlightCard(
            flight: flight,
            selectedFare: isSelected ? search.selectedFareOption : null,
            onSelectFare: (fare) {
              if (isRoundTrip && !_selectingReturnLeg) {
                // Outbound selected, now select return
                search.selectOutboundFlight(flight, fare);
                setState(() {
                  _selectingReturnLeg = true;
                });
              } else {
                // Final selection: initialize booking and navigate to booking flow
                if (isRoundTrip) {
                  search.selectReturnFlight(flight);
                } else {
                  search.selectOutboundFlight(flight, fare);
                }

                final booking = context.read<BookingProvider>();
                booking.initializeBooking(
                  flight: search.selectedOutboundFlight ?? flight,
                  returnFlight: search.selectedReturnFlight,
                  fareOption: search.selectedFareOption ?? fare,
                  adults: search.query.adults,
                  children: search.query.children,
                  infants: search.query.infants,
                  fareType: search.query.fareType,
                  promoCode: search.query.promoCode,
                );

                Navigator.pushNamed(context, '/booking');
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      children: List.generate(
        4,
        (index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 80, height: 16, color: Colors.grey.shade200),
                const Spacer(),
                Container(width: 140, height: 24, color: Colors.grey.shade200),
                const Spacer(),
                Container(width: 90, height: 32, color: Colors.grey.shade200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
