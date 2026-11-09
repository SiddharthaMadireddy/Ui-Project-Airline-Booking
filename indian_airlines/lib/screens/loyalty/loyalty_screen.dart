import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// Skyward Club loyalty screen with tier perks, progress tracker and interactive points calculator
class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  // Calculator inputs
  double _distanceKm = 1400.0;
  String _calcClass = 'Economy';

  @override
  Widget build(BuildContext context) {
    final loyalty = context.watch<LoyaltyProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

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
                      'Skyward Club - Frequent Flyer Program',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Original loyalty program for Indian Airlines. Earn points on every flight and unlock exclusive travel privileges.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Current Membership Status or Join Banner
                  if (user != null)
                    _buildMemberStatusCard(
                      context,
                      user.skywardTier,
                      user.skywardPoints,
                      loyalty,
                    )
                  else
                    _buildJoinNowCard(context),

                  const SizedBox(height: 36),

                  // 2. Three Tiers Cards: Silver, Gold, Platinum
                  const Text(
                    'Membership Tiers & Exclusive Privileges',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTiersGrid(context),

                  const SizedBox(height: 36),

                  // 3. Interactive Points Calculator
                  _buildPointsCalculator(context),
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

  Widget _buildMemberStatusCard(
    BuildContext context,
    String tier,
    int points,
    LoyaltyProvider loyalty,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppConstants.primaryNavy, Color(0xFF1E3A8A)],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$tier Member',
                      style: const TextStyle(
                        color: AppConstants.saffron,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'POINTS BALANCE',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        '$points pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Progress to Platinum Tier (${loyalty.tierPoints} / ${loyalty.platinumThreshold} Tier Points)',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: loyalty.tierProgress,
              backgroundColor: Colors.white24,
              color: AppConstants.saffron,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinNowCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not a Member Yet?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enroll today and receive 500 bonus welcome points instantly redeemable on your first booking.',
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              child: const Text('Enroll Now (Free)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTiersGrid(BuildContext context) {
    final tiers = [
      _TierData(
        title: 'Silver',
        criteria: 'Entry Level on Joining',
        color: const Color(0xFF94A3B8),
        perks: [
          'Earn 5 points per ₹100 spent',
          'Standard seat reservation',
          'Online check-in 48h prior',
          'Redeem points for flight discounts',
        ],
      ),
      _TierData(
        title: 'Gold',
        criteria: '15,000 Tier Points or 20 flights',
        color: const Color(0xFFD97706),
        perks: [
          'Earn 8 points per ₹100 spent',
          '+10 kg Complimentary baggage',
          'Priority check-in counters',
          'Free standard seat selection',
          '50% bonus points on birthday month',
        ],
      ),
      _TierData(
        title: 'Platinum',
        criteria: '35,000 Tier Points or 40 flights',
        color: const Color(0xFF475569),
        perks: [
          'Earn 12 points per ₹100 spent',
          '+15 kg Extra check-in allowance',
          'Airport Lounge access for member + 1 guest',
          'Priority baggage handling & boarding',
          'Zero cancellation fee on Flex tickets',
        ],
      ),
    ];

    final isDesktop = Responsive.isDesktop(context);

    if (!isDesktop) {
      return Column(
        children: tiers
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildTierCard(t),
              ),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tiers.map((t) => Expanded(child: _buildTierCard(t))).toList(),
    );
  }

  Widget _buildTierCard(_TierData t) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: t.color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                t.title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.criteria,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...t.perks.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check,
                      size: 14,
                      color: AppConstants.accentGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(p, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCalculator(BuildContext context) {
    final estimatedPoints = LoyaltyProvider.estimatePointsByDistance(
      distanceKm: _distanceKm,
      travelClass: _calcClass,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interactive Points Earned Calculator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Slide route distance and select cabin class to calculate potential Skyward Club points.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route Distance: ${_distanceKm.toInt()} km (e.g. BOM - DEL ~1,150 km, DEL - DXB ~2,200 km)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Slider(
                        value: _distanceKm,
                        min: 300,
                        max: 8000,
                        divisions: 77,
                        activeColor: AppConstants.primaryNavy,
                        onChanged: (val) => setState(() => _distanceKm = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _calcClass,
                    decoration: const InputDecoration(
                      labelText: 'Travel Class',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Economy',
                        child: Text('Economy'),
                      ),
                      DropdownMenuItem(
                        value: 'Premium Economy',
                        child: Text('Premium Economy'),
                      ),
                      DropdownMenuItem(
                        value: 'Business',
                        child: Text('Business'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _calcClass = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.saffron.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppConstants.saffron),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Skyward Club Points Earned:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '+$estimatedPoints Points',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppConstants.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierData {
  final String title;
  final String criteria;
  final Color color;
  final List<String> perks;

  _TierData({
    required this.title,
    required this.criteria,
    required this.color,
    required this.perks,
  });
}
