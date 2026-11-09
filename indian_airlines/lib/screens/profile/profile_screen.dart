import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../models/passenger.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// User profile screen with saved passengers, loyalty status, dark mode toggle and reset demo data
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _newPassengerNameController = TextEditingController();

  @override
  void dispose() {
    _newPassengerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final trips = context.watch<TripsProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: const TopNav(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Please sign in to view your profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
                child: const Text('Go to Sign In'),
              ),
            ],
          ),
        ),
      );
    }

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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppConstants.saffron,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppConstants.primaryNavy),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Skyward Club: ${user.skywardClubNumber} • ${user.skywardTier} Tier (${user.skywardPoints} pts)',
                            style: const TextStyle(color: AppConstants.saffron, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${user.email} • +91 ${user.phone}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
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
                  // 1. Saved Frequent Flyers
                  Card(
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
                              const Text('Saved Frequent Passengers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ElevatedButton.icon(
                                onPressed: () => _showAddPassengerDialog(context, auth),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Passenger'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (user.savedPassengers.isEmpty)
                            const Text('No saved frequent passengers yet.', style: TextStyle(color: Colors.grey))
                          else
                            ...user.savedPassengers.map(
                              (p) => ListTile(
                                dense: true,
                                leading: const Icon(Icons.person, color: AppConstants.primaryNavy),
                                title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Nationality: ${p.nationality}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                  onPressed: () => auth.removeSavedPassenger(p.id),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Settings & Demo Controls
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Application Settings & Demo Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: const Text('Dark Mode Appearance'),
                            subtitle: const Text('Toggle between Light and Dark airline themes'),
                            value: themeProvider.isDarkMode,
                            onChanged: (_) => themeProvider.toggleTheme(),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.restart_alt, color: Colors.orange),
                            title: const Text('Reset All Demo Data', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Restores seed bookings, flight check-ins and demo users for viva testing'),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await trips.resetDemoData();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Demo bookings and check-in test data reset successfully!'),
                                      backgroundColor: AppConstants.accentGreen,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
                              child: const Text('Reset Data'),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            onTap: () {
                              auth.logout();
                              Navigator.pushReplacementNamed(context, '/');
                            },
                          ),
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

  void _showAddPassengerDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Frequent Passenger'),
        content: TextField(
          controller: _newPassengerNameController,
          decoration: const InputDecoration(labelText: 'Full Name as on ID (e.g. Priya Sharma)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = _newPassengerNameController.text.trim();
              if (name.isNotEmpty) {
                final parts = name.split(' ');
                auth.addSavedPassenger(
                  Passenger(
                    id: 'sp_${DateTime.now().millisecondsSinceEpoch}',
                    title: 'Ms',
                    firstName: parts.first,
                    lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
                    nationality: 'Indian',
                    isFrequent: true,
                  ),
                );
                _newPassengerNameController.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

