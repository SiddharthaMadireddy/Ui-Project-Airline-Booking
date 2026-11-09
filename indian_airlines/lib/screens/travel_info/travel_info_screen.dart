import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../data/faq.dart';
import '../../data/local_storage.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// Prepare to Travel screen with interactive baggage calculator, persistent checklist & FAQs
class TravelInfoScreen extends StatefulWidget {
  const TravelInfoScreen({super.key});

  @override
  State<TravelInfoScreen> createState() => _TravelInfoScreenState();
}

class _TravelInfoScreenState extends State<TravelInfoScreen> {
  // Baggage calculator inputs
  String _calcClass = 'Economy Saver';
  String _calcRoute = 'Domestic';

  // Persistent checklist
  final List<String> _checklistItems = [
    'Valid Government Photo ID (Aadhaar / Driving License / Voter ID)',
    'Original Passport with minimum 6 months validity (International)',
    'Valid Visa / e-Visa / OCI card (if applicable)',
    'Digital or printed Boarding Pass',
    'Prescribed medications in original packaging',
    'Power banks & lithium batteries packed in CABIN baggage only',
    'Liquids, Aerosols & Gels within 100ml containers (Security zip lock bag)',
    'Travel Insurance policy copy',
  ];
  List<String> _checkedItems = [];

  @override
  void initState() {
    super.initState();
    _checkedItems = LocalStorage.getChecklist();
  }

  void _toggleChecklistItem(String item) {
    setState(() {
      if (_checkedItems.contains(item)) {
        _checkedItems.remove(item);
      } else {
        _checkedItems.add(item);
      }
    });
    LocalStorage.setChecklist(_checkedItems);
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
                      'Prepare to Travel - Passenger Guide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Baggage allowances calculator, airport guidelines, visa checklist and special assistance',
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
                  // 1. Interactive Baggage Calculator
                  _buildBaggageCalculator(context),

                  const SizedBox(height: 36),

                  // 2. Persistent Visa & Travel Checklist
                  _buildPersistentChecklist(context),

                  const SizedBox(height: 36),

                  // 3. Airport Information & Terminal Reporting
                  _buildAirportInfo(context),

                  const SizedBox(height: 36),

                  // 4. Baggage Guidelines FAQs (ExpansionTiles)
                  _buildBaggageFaqs(context),

                  const SizedBox(height: 36),

                  // 5. Special Health Assistance Form
                  _buildSpecialAssistanceCard(context),
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

  // --- Baggage Calculator ---
  Widget _buildBaggageCalculator(BuildContext context) {
    int checkInKg = 15;
    int cabinKg = 7;

    if (_calcClass == 'Economy Flex') {
      checkInKg = _calcRoute == 'Domestic' ? 25 : 35;
      cabinKg = 7;
    } else if (_calcClass == 'Business Class') {
      checkInKg = _calcRoute == 'Domestic' ? 35 : 40;
      cabinKg = 12;
    } else {
      checkInKg = _calcRoute == 'Domestic' ? 15 : 25;
      cabinKg = 7;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interactive Baggage Allowance Calculator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Check exact complimentary baggage dimensions and weight for your cabin class and route.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _calcClass,
                    decoration: const InputDecoration(
                      labelText: 'Cabin / Fare Family',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Economy Saver',
                        child: Text('Economy Saver'),
                      ),
                      DropdownMenuItem(
                        value: 'Economy Flex',
                        child: Text('Economy Flex'),
                      ),
                      DropdownMenuItem(
                        value: 'Business Class',
                        child: Text('Business Class'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _calcClass = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _calcRoute,
                    decoration: const InputDecoration(
                      labelText: 'Journey Type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Domestic',
                        child: Text('Domestic (Within India)'),
                      ),
                      DropdownMenuItem(
                        value: 'International',
                        child: Text('International'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _calcRoute = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Result Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.luggage,
                          color: AppConstants.primaryNavy,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Check-in Baggage',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '$checkInKg kg',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppConstants.primaryNavy,
                          ),
                        ),
                        const Text(
                          'Dimensions: L+W+H ≤ 158 cm',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.saffron.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.backpack,
                          color: AppConstants.saffron,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Cabin Hand Baggage',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '$cabinKg kg',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppConstants.primaryNavy,
                          ),
                        ),
                        const Text(
                          'Fits in overhead bin / under seat',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
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

  // --- Persistent Checklist ---
  Widget _buildPersistentChecklist(BuildContext context) {
    final progress = _checklistItems.isNotEmpty
        ? _checkedItems.length / _checklistItems.length
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Travel Readiness Checklist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Selections persist across browser refreshes via SharedPreferences',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  '${(_checkedItems.length)} / ${_checklistItems.length} Complete',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: AppConstants.accentGreen,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 16),
            ..._checklistItems.map((item) {
              final isDone = _checkedItems.contains(item);
              return CheckboxListTile(
                dense: true,
                value: isDone,
                title: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : null,
                  ),
                ),
                onChanged: (_) => _toggleChecklistItem(item),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- Airport Reporting Info ---
  Widget _buildAirportInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Airport Reporting Times & Lounge Access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: AppConstants.primaryNavy,
                    ),
                    title: Text(
                      'Domestic Flights',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Check-in opens 2h before departure and closes 60m prior. Boarding gates close 20m before takeoff.',
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      Icons.public,
                      color: AppConstants.primaryNavy,
                    ),
                    title: Text(
                      'International Flights',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Check-in opens 4h before departure and closes 75m prior. Strict passport and visa checks.',
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

  // --- FAQs ExpansionTiles ---
  Widget _buildBaggageFaqs(BuildContext context) {
    final baggageFaqs = FaqData.items
        .where((f) => f.category == 'Baggage')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Baggage Rules & Regulations FAQs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...baggageFaqs.map(
          (faq) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                faq.question,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Special Health Assistance Form ---
  Widget _buildSpecialAssistanceCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Special Health & Wheelchair Assistance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Complimentary airport escort and wheelchair assistance for senior citizens & passengers with reduced mobility.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAssistanceChip('Wheelchair to Ramp (WCHR)'),
                _buildAssistanceChip('Wheelchair to Aircraft Door (WCHS)'),
                _buildAssistanceChip('Wheelchair to Cabin Seat (WCHC)'),
                _buildAssistanceChip('Travelling with Infant / Bassinet'),
                _buildAssistanceChip('Visually / Hearing Impaired Escort'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Special assistance request registered to booking profile.',
                    ),
                    backgroundColor: AppConstants.accentGreen,
                  ),
                );
              },
              child: const Text('Submit Assistance Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistanceChip(String label) {
    return FilterChip(label: Text(label), selected: false, onSelected: (_) {});
  }
}
