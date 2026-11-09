import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// About screen explaining final lab external project specifications, viva checklist and team details
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                      'About Indian Airlines Lab Project',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Final Year External Lab Examination Project • Responsive Web Application in Flutter',
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
                  // Logo & Disclaimer Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppLogo(size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Project Summary & Design Philosophy',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Indian Airlines is a fictional demo airline web application built for an external final-year laboratory evaluation. It adheres strictly to all legal and design rules: original brand identity, CustomPainter-rendered 24-spoke soaring bird logo, original copy, and zero network images to eliminate CORS issues on web deployment.',
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConstants.saffron.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppConstants.saffron),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, color: AppConstants.primaryNavy),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'OFFICIAL DISCLAIMER: Demo project: no real bookings or payments. No affiliation with any commercial airline.',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Flutter Concepts Demonstrated
                  const Text('Flutter Concepts Demonstrated Visibly', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildConceptTable(),

                  const SizedBox(height: 28),

                  // Architecture Overview
                  const Text('System Architecture & State Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('• State Management: Provider (ChangeNotifier) with Consumer and context.watch/read.', style: TextStyle(fontSize: 13, height: 1.6)),
                          Text('• Flight Generation: Deterministic seeded generation via Random(hash(route, date)) so same searches yield consistent results.', style: TextStyle(fontSize: 13, height: 1.6)),
                          Text('• Local Storage: SharedPreferences persists user session, mock bookings, travel checklist and dark mode preferences.', style: TextStyle(fontSize: 13, height: 1.6)),
                          Text('• Pricing & Taxes: Separate PricingService computing GST, airport development fees, passenger multipliers and promo discounts.', style: TextStyle(fontSize: 13, height: 1.6)),
                          Text('• Refund Calculation: RefundService implementing commercial cancellation tiers (>24h vs <24h).', style: TextStyle(fontSize: 13, height: 1.6)),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildConceptTable() {
    const concepts = [
      ['State Management', 'Provider with SearchProvider, BookingProvider, TripsProvider, LoyaltyProvider, AuthProvider, ThemeProvider', 'lib/providers/'],
      ['Custom Graphics', 'CustomPainter for AppLogo (24-spoke chakra & wing), Barcode, Pseudo-QR and RouteNetwork map', 'lib/widgets/'],
      ['Animations', 'AnimationController for splash plane, rotate swap button, checkmark scale & flight timeline', 'lib/screens/splash/, lib/widgets/'],
      ['Form Validation', 'Form/GlobalKey, TextFormField, Luhn credit card check, email/phone regex, passport checks', 'lib/core/validators.dart'],
      ['Responsive Layout', 'Responsive breakpoints (<600, 600-1024, >1024), centered 1200 max container width', 'lib/core/responsive.dart'],
      ['Material 3 Theming', 'ColorScheme.fromSeed with Navy (#0B1F4B), Saffron (#FF9933) and Green (#138808), Light & Dark', 'lib/core/theme.dart'],
      ['Persistence', 'SharedPreferences for bookings, users, checklist, and settings with reset function', 'lib/data/local_storage.dart'],
    ];

    return Card(
      elevation: 1,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: concepts.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final c = concepts[index];
          return ListTile(
            title: Text(c[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(c[1], style: const TextStyle(fontSize: 12)),
            trailing: Text(c[2], style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
          );
        },
      ),
    );
  }
}
