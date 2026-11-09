import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../data/airports.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/footer.dart';
import '../../widgets/route_painter.dart';
import '../../widgets/top_nav.dart';

/// Where We Fly screen featuring interactive CustomPainter route map & flight schedule DataTable
class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _filter = 'All'; // All, Domestic, International
  String _searchQuery = '';
  String? _selectedHub;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
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
                      'Where We Fly - Network Route Map',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Connecting 25 premier Indian destinations and 15 global mega-hubs across Europe, Middle East and Asia',
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
                  // 1. CustomPainter Route Map Canvas
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Interactive Route Network Map',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  _buildLegendDot(AppConstants.primaryNavy, 'Main Hub'),
                                  const SizedBox(width: 12),
                                  _buildLegendDot(AppConstants.saffron, 'Active Flight Route'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 380,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppConstants.borderLight),
                            ),
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: RouteNetworkPainter(
                                    animationValue: _animController.value,
                                    selectedNode: _selectedHub,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 2. Searchable Destinations List
                  const Text(
                    'Destinations Directory',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Search city, airport or 3-letter code (e.g. London, DXB)',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'All', label: Text('All')),
                          ButtonSegment(value: 'Domestic', label: Text('Domestic')),
                          ButtonSegment(value: 'International', label: Text('International')),
                        ],
                        selected: {_filter},
                        onSelectionChanged: (set) => setState(() => _filter = set.first),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Destination Grid
                  _buildFilteredDestinationGrid(),

                  const SizedBox(height: 48),

                  // 3. Flight Timetable Schedule DataTable
                  const Text(
                    'Daily Flight Schedule Timetable',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildScheduleDataTable(context),
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

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFilteredDestinationGrid() {
    var list = AirportData.search(_searchQuery);
    if (_filter == 'Domestic') {
      list = list.where((a) => a.isDomestic).toList();
    } else if (_filter == 'International') {
      list = list.where((a) => !a.isDomestic).toList();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 80,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final apt = list[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: AppConstants.primaryNavy.withValues(alpha: 0.1),
              child: Text(
                apt.code,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppConstants.primaryNavy),
              ),
            ),
            title: Text(apt.city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(apt.country, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            onTap: () {
              setState(() {
                _selectedHub = apt.code;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildScheduleDataTable(BuildContext context) {
    const schedules = [
      ['IA-204', 'Delhi (DEL)', 'Mumbai (BOM)', '06:00', '08:15', 'Daily', 'Airbus A321neo'],
      ['IA-312', 'Mumbai (BOM)', 'Bengaluru (BLR)', '08:30', '10:15', 'Daily', 'Airbus A320neo'],
      ['IA-450', 'Bengaluru (BLR)', 'Hyderabad (HYD)', '11:00', '12:10', 'Daily', 'Boeing 737 MAX'],
      ['IA-582', 'Delhi (DEL)', 'Dubai (DXB)', '14:20', '16:50', 'Daily', 'Boeing 787-9'],
      ['IA-710', 'Delhi (DEL)', 'London (LHR)', '03:15', '07:45', 'Mon, Wed, Fri', 'Boeing 787-9'],
      ['IA-890', 'Bengaluru (BLR)', 'Singapore (SIN)', '23:10', '06:00', 'Daily', 'Airbus A350-900'],
      ['IA-922', 'Mumbai (BOM)', 'Goa (GOI)', '16:45', '18:00', 'Daily', 'Airbus A320neo'],
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Flight #', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Origin', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Destination', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Dep', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Arr', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Aircraft', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: schedules.map((s) {
            return DataRow(
              cells: [
                DataCell(Text(s[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryNavy))),
                DataCell(Text(s[1])),
                DataCell(Text(s[2])),
                DataCell(Text(s[3])),
                DataCell(Text(s[4])),
                DataCell(Text(s[5])),
                DataCell(Text(s[6])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
