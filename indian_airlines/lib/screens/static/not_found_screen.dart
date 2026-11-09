import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// 404 Route Not Found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNav(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            ResponsiveContainer(
              maxWidth: 600,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flight_land, size: 72, color: AppConstants.saffron),
                      const SizedBox(height: 16),
                      const Text(
                        '404 - Flight Path Not Found',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppConstants.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The page or route you navigated to has been redirected or does not exist.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                        icon: const Icon(Icons.home),
                        label: const Text('Return to Home Page'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

