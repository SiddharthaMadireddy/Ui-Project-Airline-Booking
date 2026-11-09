import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/responsive.dart';
import '../../data/airports.dart';
import '../../data/destinations.dart';
import '../../data/offers.dart';
import '../../models/offer.dart';
import '../../providers/search_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/footer.dart';
import '../../widgets/notice_ticker.dart';
import '../../widgets/search_widget.dart';
import '../../widgets/top_nav.dart';

/// Home screen featuring hero with search widget, deals tabs, destination cards and loyalty banner
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _dealTabController;
  final _emailNewsletterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dealTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _dealTabController.dispose();
    _emailNewsletterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNav(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NoticeTicker(),
            _buildHeroWithSearch(context),
            const SizedBox(height: 32),
            _buildExclusiveDealsSection(context),
            const SizedBox(height: 48),
            _buildFeaturedDestinations(context),
            const SizedBox(height: 48),
            _buildPlanYourTripSection(context),
            const SizedBox(height: 48),
            _buildLoyaltyBanner(context),
            const SizedBox(height: 48),
            _buildAppDownloadSection(context),
            const SizedBox(height: 48),
            _buildNewsletterSection(context),
            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  // --- 1. Hero with Animated Sky Gradient & Search Widget ---
  Widget _buildHeroWithSearch(BuildContext context) {
    return Stack(
      children: [
        // Sky Background
        Container(
          height: 420,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryNavy,
                Color(0xFF1E3A8A),
                Color(0xFF2563EB),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Stylized Sun/Chakra Glow
              Positioned(
                top: 40,
                right: 80,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.saffron.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Hero Headline
              Positioned(
                top: 36,
                left: 0,
                right: 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fly High with Indian Pride',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Book domestic and international flights with zero convenience fee on UPI',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Widget Card overlapping Hero
        Padding(
          padding: const EdgeInsets.only(top: 140),
          child: ResponsiveContainer(
            child: const SearchWidget(),
          ),
        ),
      ],
    );
  }

  // --- 2. Exclusive Deals Section ---
  Widget _buildExclusiveDealsSection(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exclusive Deals & Offers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppConstants.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Save extra on your next journey with promo codes & partner bank discounts',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _dealTabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppConstants.saffron,
              labelColor: AppConstants.primaryNavy,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Bank offers'),
                Tab(text: 'Discount codes'),
                Tab(text: 'Limited-time'),
                Tab(text: 'Special fares'),
              ],
              onTap: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          // Filtered Offer Cards Grid
          Builder(
            builder: (context) {
              final categories = ['Bank offers', 'Discount codes', 'Limited-time', 'Special fares'];
              final activeCategory = categories[_dealTabController.index];
              final categoryOffers =
                  OffersData.offers.where((o) => o.category == activeCategory).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380,
                  mainAxisExtent: 195,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categoryOffers.length,
                itemBuilder: (context, index) {
                  final offer = categoryOffers[index];
                  return _buildOfferCard(context, offer);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, Offer offer) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppConstants.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    offer.badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryNavy,
                    ),
                  ),
                ),
                Text(
                  offer.expiry,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  offer.description,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppConstants.saffron, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    offer.code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: AppConstants.primaryNavy,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: offer.code));
                    context.read<SearchProvider>().setPromoCode(offer.code);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code ${offer.code} applied & copied!'),
                        backgroundColor: AppConstants.accentGreen,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Apply Code', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Book Nonstop Direct Flights Destination Cards ---
  Widget _buildFeaturedDestinations(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Nonstop Direct Flights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppConstants.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Popular domestic gateways and international dream destinations',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 220,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: DestinationsData.destinations.length,
            itemBuilder: (context, index) {
              final dest = DestinationsData.destinations[index];
              return _buildDestinationCard(context, dest);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, DestinationCardData dest) {
    return InkWell(
      onTap: () async {
        final search = context.read<SearchProvider>();
        final origin = AirportData.findByCode(dest.defaultOriginCode);
        final destination = AirportData.findByCode(dest.code);
        if (origin != null && destination != null) {
          search.setOrigin(origin);
          search.setDestination(destination);
          Navigator.pushNamed(context, '/search');
          await search.searchFlights();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dest.gradientColors,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dest.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(dest.icon, color: Colors.white70, size: 28),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dest.city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  dest.country,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  dest.tagline,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'from ${AppFormatters.formatCurrency(dest.startingFare)}',
                    style: const TextStyle(
                      color: AppConstants.saffron,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. Plan Your Trip Tiles ---
  Widget _buildPlanYourTripSection(BuildContext context) {
    final tiles = [
      _TripTileData(Icons.luggage, 'Baggage Guidelines', 'Allowances & rules', () => Navigator.pushNamed(context, '/travel-info')),
      _TripTileData(Icons.support_agent, 'Customer Support', '24/7 helpdesk & FAQs', () => Navigator.pushNamed(context, '/support')),
      _TripTileData(Icons.hub, 'Airline Alliances', 'Fictional SkyAlliance network', () => _showTripInfoDialog(context, 'Global Alliances', 'Indian Airlines partners with fictional global carrier networks to offer smooth codeshare transfers across 120+ countries.')),
      _TripTileData(Icons.hotel, 'Hotels & Stays', 'Special airport transit hotel deals', () => _showTripInfoDialog(context, 'Hotel Partner Deals', 'Earn 500 bonus Skyward Club points on every hotel booking through our fictional hospitality partners.')),
      _TripTileData(Icons.directions_car, 'Airport Transfers', 'Pre-booked airport taxis', () => _showTripInfoDialog(context, 'Airport Cab Booking', 'Flat-rate city transfers directly from Terminal T3 and T2 arrival curbsides.')),
      _TripTileData(Icons.card_giftcard, 'Travel Gift Cards', 'Give the gift of travel', () => _showTripInfoDialog(context, 'Indian Airlines Gift Cards', 'Digital vouchers valid for 12 months across all domestic and international scheduled flights.')),
    ];

    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Your Trip',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppConstants.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Everything you need before, during and after your flight',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 380,
              mainAxisExtent: 85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, index) {
              final t = tiles[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppConstants.borderLight),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.primaryNavy.withValues(alpha: 0.1),
                    child: Icon(t.icon, color: AppConstants.primaryNavy, size: 20),
                  ),
                  title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(t.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: t.onTap,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTripInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // --- 5. Skyward Club Banner ---
  Widget _buildLoyaltyBanner(BuildContext context) {
    return ResponsiveContainer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppConstants.primaryNavy, Color(0xFF1E293B)],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.saffron,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'SKYWARD CLUB LOYALTY',
                      style: TextStyle(
                        color: AppConstants.primaryNavy,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fly More, Earn Points & Unlock Free Flights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join 2+ million members enjoying priority lounge access, extra 15 kg baggage, and redemption discounts on every ticket.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/loyalty'),
                    child: const Text('Join Skyward Club Now'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            const Icon(
              Icons.workspace_premium,
              color: AppConstants.saffron,
              size: 90,
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. App Download Section (Drawn with Widgets) ---
  Widget _buildAppDownloadSection(BuildContext context) {
    return ResponsiveContainer(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppConstants.lightBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Download Indian Airlines Mobile Experience',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Get instant flight status alerts, offline digital boarding passes, and web check-in reminders.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Fake App Store / Play Store Badges drawn purely with Flutter widgets
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildFakeStoreBadge('Google Play', Icons.android),
                      _buildFakeStoreBadge('App Store', Icons.apple),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.phone_iphone, size: 70, color: AppConstants.primaryNavy),
          ],
        ),
      ),
    );
  }

  Widget _buildFakeStoreBadge(String storeName, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.primaryNavy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('DOWNLOAD ON', style: TextStyle(color: Colors.white60, fontSize: 8)),
              Text(storeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // --- 7. Newsletter Section ---
  Widget _buildNewsletterSection(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return ResponsiveContainer(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.borderLight),
        ),
        child: isDesktop
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Stay Updated with Fare Alerts',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Subscribe to receive weekly flash sales, student discounts and destination guides.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 340,
                    child: _buildNewsletterInput(context),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stay Updated with Fare Alerts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Subscribe to receive weekly flash sales, student discounts and destination guides.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildNewsletterInput(context),
                ],
              ),
      ),
    );
  }

  Widget _buildNewsletterInput(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _emailNewsletterController,
            decoration: const InputDecoration(
              hintText: 'Enter email address',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            final email = _emailNewsletterController.text.trim();
            if (email.contains('@')) {
              _emailNewsletterController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! You are now subscribed to fare alerts.'),
                  backgroundColor: AppConstants.accentGreen,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid email address')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          child: const Text('Subscribe'),
        ),
      ],
    );
  }
}

class _TripTileData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  _TripTileData(this.icon, this.title, this.subtitle, this.onTap);
}
