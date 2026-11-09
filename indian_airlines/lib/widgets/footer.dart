import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/responsive.dart';
import 'app_logo.dart';

/// Global footer with multi-column links, social icons and required college demo disclaimer
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppConstants.primaryNavy,
      padding: const EdgeInsets.only(top: 48, bottom: 24, left: 24, right: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Brand & Socials
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  const AppLogo(
                    size: 36,
                    variant: LogoVariant.whiteOnDark,
                  ),
                  Wrap(
                    spacing: 12,
                    children: [
                      _SocialIcon(icon: Icons.facebook, onTap: () {}),
                      _SocialIcon(icon: Icons.camera_alt, onTap: () {}),
                      _SocialIcon(icon: Icons.alternate_email, onTap: () {}),
                      _SocialIcon(icon: Icons.ondemand_video, onTap: () {}),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Links Columns
              Responsive(
                mobile: _buildMobileLinks(context),
                desktop: _buildDesktopLinks(context),
              ),

              const SizedBox(height: 40),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 24),

              // Prominent Fictional Demo Airline Disclaimer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppConstants.saffron,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'DISCLAIMER: ${AppConstants.demoDisclaimer}. Indian Airlines is an educational final-year lab project. No real tickets, airlines or flights are affiliated.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bottom copyright row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    '© ${DateTime.now().year} Indian Airlines Demo Project. Built with Flutter Web.',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/about'),
                    child: const Text(
                      'About Project & Viva Notes',
                      style: TextStyle(
                        color: AppConstants.saffron,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLinks(BuildContext context) {
    return Wrap(
      spacing: 36,
      runSpacing: 24,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _FooterColumn(
          title: 'Book & Manage',
          items: [
            _FooterItem('Book Flights', () => Navigator.pushNamed(context, '/')),
            _FooterItem('Manage Booking', () => Navigator.pushNamed(context, '/manage')),
            _FooterItem('Web Check-in', () => Navigator.pushNamed(context, '/checkin')),
            _FooterItem('Flight Status', () => Navigator.pushNamed(context, '/status')),
          ],
        ),
        _FooterColumn(
          title: 'Where We Fly',
          items: [
            _FooterItem('Route Network Map', () => Navigator.pushNamed(context, '/destinations')),
            _FooterItem('Domestic Destinations', () => Navigator.pushNamed(context, '/destinations')),
            _FooterItem('International Hubs', () => Navigator.pushNamed(context, '/destinations')),
            _FooterItem('Flight Schedules', () => Navigator.pushNamed(context, '/destinations')),
          ],
        ),
        _FooterColumn(
          title: 'Prepare to Travel',
          items: [
            _FooterItem('Baggage Guidelines', () => Navigator.pushNamed(context, '/travel-info')),
            _FooterItem('Airport Information', () => Navigator.pushNamed(context, '/travel-info')),
            _FooterItem('Visa & Travel Checklist', () => Navigator.pushNamed(context, '/travel-info')),
            _FooterItem('Special Assistance', () => Navigator.pushNamed(context, '/travel-info')),
          ],
        ),
        _FooterColumn(
          title: 'Skyward Club',
          items: [
            _FooterItem('Join Skyward Club', () => Navigator.pushNamed(context, '/loyalty')),
            _FooterItem('Tier Privileges', () => Navigator.pushNamed(context, '/loyalty')),
            _FooterItem('Points Calculator', () => Navigator.pushNamed(context, '/loyalty')),
            _FooterItem('Redeem Rewards', () => Navigator.pushNamed(context, '/loyalty')),
          ],
        ),
        _FooterColumn(
          title: 'Support & About',
          items: [
            _FooterItem('Customer FAQs', () => Navigator.pushNamed(context, '/support')),
            _FooterItem('Contact Us Form', () => Navigator.pushNamed(context, '/support')),
            _FooterItem('Feedback & Concerns', () => Navigator.pushNamed(context, '/support')),
            _FooterItem('Final Lab Project Info', () => Navigator.pushNamed(context, '/about')),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLinks(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 24,
      children: [
        _FooterColumn(
          title: 'Book & Manage',
          items: [
            _FooterItem('Book Flight', () => Navigator.pushNamed(context, '/')),
            _FooterItem('Manage Booking', () => Navigator.pushNamed(context, '/manage')),
            _FooterItem('Web Check-in', () => Navigator.pushNamed(context, '/checkin')),
            _FooterItem('Flight Status', () => Navigator.pushNamed(context, '/status')),
          ],
        ),
        _FooterColumn(
          title: 'Quick Links',
          items: [
            _FooterItem('Where We Fly', () => Navigator.pushNamed(context, '/destinations')),
            _FooterItem('Prepare to Travel', () => Navigator.pushNamed(context, '/travel-info')),
            _FooterItem('Skyward Club', () => Navigator.pushNamed(context, '/loyalty')),
            _FooterItem('Support & FAQs', () => Navigator.pushNamed(context, '/support')),
            _FooterItem('About Project', () => Navigator.pushNamed(context, '/about')),
          ],
        ),
      ],
    );
  }
}

class _FooterItem {
  final String label;
  final VoidCallback onTap;
  _FooterItem(this.label, this.onTap);
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<_FooterItem> items;

  const _FooterColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: item.onTap,
              child: Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
