import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../models/flight.dart';
import '../models/passenger.dart';
import '../models/user.dart';
import 'airports.dart';

/// Local persistence service using SharedPreferences with in-memory caching
class LocalStorage {
  static const String _keyUser = 'ia_current_user';
  static const String _keyBookings = 'ia_user_bookings';
  static const String _keyDarkMode = 'ia_is_dark_mode';
  static const String _keyChecklist = 'ia_travel_checklist';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Theme Mode ---
  static bool getDarkMode() {
    return _prefs?.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool(_keyDarkMode, isDark);
  }

  // --- Travel Checklist ---
  static List<String> getChecklist() {
    return _prefs?.getStringList(_keyChecklist) ?? [];
  }

  static Future<void> setChecklist(List<String> items) async {
    await _prefs?.setStringList(_keyChecklist, items);
  }

  // --- Current User ---
  static User? getUser() {
    final raw = _prefs?.getString(_keyUser);
    if (raw == null || raw.isEmpty) {
      // Default demo user
      return const User(
        id: 'u_101',
        name: 'Rahul Sharma',
        email: 'rahul.sharma@example.com',
        phone: '9876543210',
        skywardClubNumber: 'SK-882194',
        skywardTier: 'Gold',
        skywardPoints: 3450,
        savedPassengers: [
          Passenger(
            id: 'sp_1',
            title: 'Mr',
            firstName: 'Rahul',
            lastName: 'Sharma',
            nationality: 'Indian',
            isFrequent: true,
          ),
          Passenger(
            id: 'sp_2',
            title: 'Mrs',
            firstName: 'Priya',
            lastName: 'Sharma',
            nationality: 'Indian',
            isFrequent: true,
          ),
        ],
      );
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUser(User? user) async {
    if (user == null) {
      await _prefs?.remove(_keyUser);
    } else {
      await _prefs?.setString(_keyUser, jsonEncode(user.toJson()));
    }
  }

  // --- Seed Demo Bookings ---
  static List<Booking> _generateSeedBookings() {
    final now = DateTime.now();

    // 1. Eligible for Web Check-in (departure in 18 hours, inside the 48h-2h window!)
    final bom = AirportData.findByCode('BOM')!;
    final del = AirportData.findByCode('DEL')!;
    final dxb = AirportData.findByCode('DXB')!;
    final blr = AirportData.findByCode('BLR')!;
    final goi = AirportData.findByCode('GOI')!;

    final flight1Dep = now.add(const Duration(hours: 18));
    final flight1Arr = flight1Dep.add(const Duration(minutes: 130));

    final flight1 = Flight(
      flightNumber: 'IA-204',
      origin: bom,
      destination: del,
      departureTime: flight1Dep,
      arrivalTime: flight1Arr,
      durationMinutes: 130,
      stops: 0,
      aircraft: 'Airbus A321neo',
      basePrice: 4200,
      fares: const [],
    );

    final booking1 = Booking(
      pnr: 'IA7K9P',
      flight: flight1,
      passengers: const [
        Passenger(
          id: 'p_1',
          title: 'Mr',
          firstName: 'Rahul',
          lastName: 'Sharma',
          nationality: 'Indian',
          type: 'Adult',
          seatNumber: '12B',
        ),
        Passenger(
          id: 'p_2',
          title: 'Mrs',
          firstName: 'Priya',
          lastName: 'Sharma',
          nationality: 'Indian',
          type: 'Adult',
          seatNumber: '12C',
        ),
      ],
      fareFamily: 'Economy Flex',
      travelClass: 'Economy',
      status: BookingStatus.confirmed,
      bookingDate: now.subtract(const Duration(days: 4)),
      contactEmail: 'rahul.sharma@example.com',
      contactPhone: '9876543210',
      pricing: const PricingBreakdown(
        baseFare: 8400,
        taxesAndFees: 1200,
        fuelSurcharge: 800,
        convenienceFee: 350,
        grandTotal: 10750,
      ),
      paymentMethod: 'UPI',
      isCheckedIn: false,
    );

    // 2. Future International Booking (>24h away, ideal for cancellation/refund testing)
    final flight2Dep = now.add(const Duration(days: 6));
    final flight2Arr = flight2Dep.add(const Duration(minutes: 240));

    final flight2 = Flight(
      flightNumber: 'IA-582',
      origin: del,
      destination: dxb,
      departureTime: flight2Dep,
      arrivalTime: flight2Arr,
      durationMinutes: 240,
      stops: 0,
      aircraft: 'Boeing 787-9 Dreamliner',
      basePrice: 15500,
      fares: const [],
    );

    final booking2 = Booking(
      pnr: 'IA3X2M',
      flight: flight2,
      passengers: const [
        Passenger(
          id: 'p_3',
          title: 'Mr',
          firstName: 'Amit',
          lastName: 'Verma',
          nationality: 'Indian',
          passportNumber: 'Z5819204',
          type: 'Adult',
          seatNumber: '4A',
        ),
      ],
      fareFamily: 'Business',
      travelClass: 'Business',
      status: BookingStatus.confirmed,
      bookingDate: now.subtract(const Duration(days: 2)),
      contactEmail: 'amit.verma@example.com',
      contactPhone: '9123456780',
      pricing: const PricingBreakdown(
        baseFare: 37200,
        taxesAndFees: 4500,
        fuelSurcharge: 2000,
        convenienceFee: 500,
        grandTotal: 44200,
      ),
      paymentMethod: 'Credit Card',
      isCheckedIn: false,
    );

    // 3. Past Completed Trip
    final flight3Dep = now.subtract(const Duration(days: 12));
    final flight3Arr = flight3Dep.add(const Duration(minutes: 85));

    final flight3 = Flight(
      flightNumber: 'IA-710',
      origin: blr,
      destination: goi,
      departureTime: flight3Dep,
      arrivalTime: flight3Arr,
      durationMinutes: 85,
      stops: 0,
      aircraft: 'Airbus A320neo',
      basePrice: 3200,
      fares: const [],
    );

    final booking3 = Booking(
      pnr: 'IA9L1W',
      flight: flight3,
      passengers: const [
        Passenger(
          id: 'p_4',
          title: 'Mr',
          firstName: 'Rahul',
          lastName: 'Sharma',
          nationality: 'Indian',
          type: 'Adult',
          seatNumber: '14D',
        ),
      ],
      fareFamily: 'Economy Saver',
      travelClass: 'Economy',
      status: BookingStatus.completed,
      bookingDate: now.subtract(const Duration(days: 25)),
      contactEmail: 'rahul.sharma@example.com',
      contactPhone: '9876543210',
      pricing: const PricingBreakdown(
        baseFare: 3200,
        taxesAndFees: 600,
        fuelSurcharge: 400,
        convenienceFee: 250,
        grandTotal: 4450,
      ),
      paymentMethod: 'UPI',
      isCheckedIn: true,
    );

    return [booking1, booking2, booking3];
  }

  // --- Bookings ---
  static List<Booking> getBookings() {
    final raw = _prefs?.getString(_keyBookings);
    if (raw == null || raw.isEmpty) {
      final seeded = _generateSeedBookings();
      saveBookings(seeded);
      return seeded;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => Booking.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      final seeded = _generateSeedBookings();
      saveBookings(seeded);
      return seeded;
    }
  }

  static Future<void> saveBookings(List<Booking> bookings) async {
    final raw = jsonEncode(bookings.map((b) => b.toJson()).toList());
    await _prefs?.setString(_keyBookings, raw);
  }

  static Future<void> addBooking(Booking booking) async {
    final current = getBookings();
    current.insert(0, booking);
    await saveBookings(current);
  }

  static Future<void> updateBooking(Booking booking) async {
    final current = getBookings();
    final idx = current.indexWhere((b) => b.pnr == booking.pnr);
    if (idx != -1) {
      current[idx] = booking;
      await saveBookings(current);
    }
  }

  /// Reset all demo data to fresh initial state
  static Future<void> resetDemoData() async {
    await _prefs?.remove(_keyUser);
    await _prefs?.remove(_keyBookings);
    await _prefs?.remove(_keyChecklist);
    saveBookings(_generateSeedBookings());
  }
}
