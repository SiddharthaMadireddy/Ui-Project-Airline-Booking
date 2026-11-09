import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'app_logo.dart';

/// Navigation drawer for mobile devices
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Drawer(
      backgroundColor: isDark ? AppConstants.darkBg : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkCard : AppConstants.primaryNavy,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const AppLogo(
                  size: 32,
                  variant: LogoVariant.whiteOnDark,
                ),
                const SizedBox(height: 16),
                if (user != null) ...[
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.saffron,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${user.skywardTier} Tier',
                          style: const TextStyle(
                            color: AppConstants.primaryNavy,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${user.skywardPoints} pts',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'Welcome to Indian Airlines',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/auth');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.saffron,
                      foregroundColor: AppConstants.primaryNavy,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Sign In / Register'),
                  ),
                ],
              ],
            ),
          ),

          // Menu Items
          _DrawerTile(
            icon: Icons.flight_takeoff,
            title: 'Book Flights',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),
          _DrawerTile(
            icon: Icons.edit_calendar_outlined,
            title: 'Manage Booking',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/manage');
            },
          ),
          _DrawerTile(
            icon: Icons.qr_code_scanner,
            title: 'Web Check-in',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/checkin');
            },
          ),
          _DrawerTile(
            icon: Icons.access_time_rounded,
            title: 'Flight Status',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/status');
            },
          ),
          const Divider(),
          _DrawerTile(
            icon: Icons.public,
            title: 'Where We Fly & Route Map',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/destinations');
            },
          ),
          _DrawerTile(
            icon: Icons.luggage_outlined,
            title: 'Prepare to Travel (Baggage & Visas)',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/travel-info');
            },
          ),
          _DrawerTile(
            icon: Icons.workspace_premium,
            title: 'Skyward Club Loyalty',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/loyalty');
            },
          ),
          _DrawerTile(
            icon: Icons.contact_support_outlined,
            title: 'Customer Support & FAQs',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/support');
            },
          ),
          _DrawerTile(
            icon: Icons.school_outlined,
            title: 'About Project & Viva Notes',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),

          const Divider(),

          // Dark Mode Switch
          SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(fontSize: 14)),
            value: isDark,
            onChanged: (val) => themeProvider.toggleTheme(),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode_outlined),
          ),

          if (user != null) ...[
            _DrawerTile(
              icon: Icons.person_outline,
              title: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            _DrawerTile(
              icon: Icons.logout,
              title: 'Sign Out',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                authProvider.logout();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}

