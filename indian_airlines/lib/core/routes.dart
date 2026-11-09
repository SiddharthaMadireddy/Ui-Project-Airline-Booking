import 'package:flutter/material.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/checkin/checkin_screen.dart';
import '../screens/destinations/destinations_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/loyalty/loyalty_screen.dart';
import '../screens/manage/manage_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/static/about_screen.dart';
import '../screens/static/not_found_screen.dart';
import '../screens/status/status_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/travel_info/travel_info_screen.dart';

/// AppRoutes configuration demonstrating onGenerateRoute and clean web URL handling
class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String search = '/search';
  static const String booking = '/booking';
  static const String manage = '/manage';
  static const String checkin = '/checkin';
  static const String status = '/status';
  static const String destinations = '/destinations';
  static const String travelInfo = '/travel-info';
  static const String loyalty = '/loyalty';
  static const String auth = '/auth';
  static const String profile = '/profile';
  static const String support = '/support';
  static const String about = '/about';
  static const String notFound = '/not-found';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? home;
    final Object? args = settings.arguments;

    Widget page;

    // Route matching
    switch (routeName) {
      case splash:
        page = const SplashScreen();
        break;
      case home:
        page = const HomeScreen();
        break;
      case search:
        page = SearchScreen(query: args is String ? args : null);
        break;
      case booking:
        page = BookingScreen(initialStep: args is String ? args : null);
        break;
      case manage:
        page = ManageScreen(initialLookup: args is Map<String, dynamic> ? args : null);
        break;
      case checkin:
        page = CheckinScreen(initialLookup: args is Map<String, dynamic> ? args : null);
        break;
      case status:
        page = StatusScreen(initialFlightNumber: args is String ? args : null);
        break;
      case destinations:
        page = const DestinationsScreen();
        break;
      case travelInfo:
        page = const TravelInfoScreen();
        break;
      case loyalty:
        page = const LoyaltyScreen();
        break;
      case auth:
        page = const AuthScreen();
        break;
      case profile:
        page = const ProfileScreen();
        break;
      case support:
        page = const SupportScreen();
        break;
      case about:
        page = const AboutScreen();
        break;
      default:
        page = const NotFoundScreen();
        break;
    }

    // Custom smooth page transition for web
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
