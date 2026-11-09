import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/responsive.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'app_logo.dart';

/// Responsive top navigation bar for desktop and mobile headers
class TopNav extends StatelessWidget implements PreferredSizeWidget {
  const TopNav({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCard : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppConstants.borderDark : AppConstants.borderLight,
          ),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Mobile Hamburger Drawer button
                if (!isDesktop) ...[
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu),
                      tooltip: 'Open Navigation Drawer',
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // App Logo
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/'),
                  child: AppLogo(
                    size: 30,
                    variant: isDesktop
                        ? (isDark ? LogoVariant.whiteOnDark : LogoVariant.full)
                        : LogoVariant.iconOnly,
                  ),
                ),

                if (isDesktop)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildNavMenu(context, 'Book & Manage', [
                              _MenuOption(
                                'Book Flight',
                                () => Navigator.pushNamed(context, '/'),
                              ),
                              _MenuOption(
                                'Manage Booking',
                                () => Navigator.pushNamed(context, '/manage'),
                              ),
                              _MenuOption(
                                'Web Check-in',
                                () => Navigator.pushNamed(context, '/checkin'),
                              ),
                              _MenuOption(
                                'Flight Status',
                                () => Navigator.pushNamed(context, '/status'),
                              ),
                            ]),
                            _buildNavMenu(context, 'Where We Fly', [
                              _MenuOption(
                                'Route Map',
                                () => Navigator.pushNamed(context, '/destinations'),
                              ),
                              _MenuOption(
                                'Destinations & Schedules',
                                () => Navigator.pushNamed(context, '/destinations'),
                              ),
                            ]),
                            _buildNavMenu(context, 'Prepare to Travel', [
                              _MenuOption(
                                'Baggage Guidelines',
                                () => Navigator.pushNamed(context, '/travel-info'),
                              ),
                              _MenuOption(
                                'Airport Information',
                                () => Navigator.pushNamed(context, '/travel-info'),
                              ),
                              _MenuOption(
                                'Travel Checklist & Visas',
                                () => Navigator.pushNamed(context, '/travel-info'),
                              ),
                            ]),
                            _buildNavButton(
                              context,
                              'Skyward Club',
                              () => Navigator.pushNamed(context, '/loyalty'),
                            ),
                            _buildNavButton(
                              context,
                              'Support',
                              () => Navigator.pushNamed(context, '/support'),
                            ),
                            const SizedBox(width: 4),
                            const VerticalDivider(width: 12, indent: 22, endIndent: 22),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),

                // Language Dropdown
                PopupMenuButton<String>(
                  icon: const Icon(Icons.language, size: 20),
                  tooltip: 'Select Language',
                  onSelected: (lang) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language set to $lang (Demo UI)'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'English',
                      child: Text('English (EN)'),
                    ),
                    PopupMenuItem(
                      value: 'Hindi',
                      child: Text('हिन्दी (Hindi)'),
                    ),
                    PopupMenuItem(
                      value: 'Telugu',
                      child: Text('తెలుగు (Telugu)'),
                    ),
                    PopupMenuItem(value: 'Tamil', child: Text('தமிழ் (Tamil)')),
                  ],
                ),

                // Theme Toggle (Dark / Light)
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                    size: 20,
                  ),
                  tooltip: isDark
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                  onPressed: () => themeProvider.toggleTheme(),
                ),

                const SizedBox(width: 6),

                // Auth Section / User Menu
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.isLoggedIn && auth.currentUser != null) {
                      final user = auth.currentUser!;
                      return PopupMenuButton<String>(
                        tooltip: 'Account Menu',
                        offset: const Offset(0, 48),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppConstants.saffron,
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: AppConstants.primaryNavy,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 6),
                                Text(
                                  user.name.split(' ').first,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppConstants.primaryNavy,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, size: 16),
                              ],
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline, size: 18),
                                const SizedBox(width: 8),
                                Text('My Profile (${user.skywardTier})'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'trips',
                            child: Row(
                              children: [
                                Icon(Icons.flight_takeoff, size: 18),
                                SizedBox(width: 8),
                                Text('My Trips'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'about',
                            child: Row(
                              children: [
                                Icon(Icons.school_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Viva Notes & About'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (val) {
                          if (val == 'profile') {
                            Navigator.pushNamed(context, '/profile');
                          } else if (val == 'trips') {
                            Navigator.pushNamed(context, '/manage');
                          } else if (val == 'about') {
                            Navigator.pushNamed(context, '/about');
                          } else if (val == 'logout') {
                            auth.logout();
                          }
                        },
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/auth'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Sign In'),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildNavMenu(
    BuildContext context,
    String title,
    List<_MenuOption> options,
  ) {
    return PopupMenuButton<VoidCallback>(
      offset: const Offset(0, 48),
      tooltip: title,
      onSelected: (callback) => callback(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down, size: 14),
          ],
        ),
      ),
      itemBuilder: (context) => options
          .map(
            (opt) => PopupMenuItem<VoidCallback>(
              value: opt.onTap,
              child: Text(opt.title),
            ),
          )
          .toList(),
    );
  }
}

class _MenuOption {
  final String title;
  final VoidCallback onTap;
  _MenuOption(this.title, this.onTap);
}
