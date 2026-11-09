import 'package:flutter/material.dart';
import '../data/local_storage.dart';
import '../models/passenger.dart';
import '../models/user.dart';

/// Provider managing authentication state, session persistence and saved profiles
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider() {
    _currentUser = LocalStorage.getUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    // Demo authentication: Accept any valid-looking credentials
    final user = User(
      id: 'u_${email.hashCode.abs()}',
      name: email.contains('@')
          ? email.split('@').first.replaceAll('.', ' ').toUpperCase()
          : 'Valued Passenger',
      email: email.trim(),
      phone: '9876543210',
      skywardClubNumber: 'SK-${(email.hashCode.abs() % 900000) + 100000}',
      skywardTier: 'Gold',
      skywardPoints: 2850,
      savedPassengers: [
        Passenger(
          id: 'sp_1',
          title: 'Mr',
          firstName: email.split('@').first,
          lastName: 'Traveler',
          nationality: 'Indian',
          isFrequent: true,
        ),
      ],
    );

    _currentUser = user;
    await LocalStorage.saveUser(user);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final user = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      skywardClubNumber: 'SK-${(DateTime.now().millisecondsSinceEpoch % 900000) + 100000}',
      skywardTier: 'Silver',
      skywardPoints: 500, // Welcome bonus points!
      savedPassengers: [
        Passenger(
          id: 'sp_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Mr',
          firstName: name.split(' ').first,
          lastName: name.split(' ').length > 1
              ? name.split(' ').sublist(1).join(' ')
              : '',
          nationality: 'Indian',
          isFrequent: true,
        ),
      ],
    );

    _currentUser = user;
    await LocalStorage.saveUser(user);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await LocalStorage.saveUser(null);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(name: name, phone: phone);
    _currentUser = updated;
    await LocalStorage.saveUser(updated);
    notifyListeners();
  }

  Future<void> addSavedPassenger(Passenger passenger) async {
    if (_currentUser == null) return;
    final currentList = List<Passenger>.from(_currentUser!.savedPassengers);
    currentList.add(passenger);
    final updated = _currentUser!.copyWith(savedPassengers: currentList);
    _currentUser = updated;
    await LocalStorage.saveUser(updated);
    notifyListeners();
  }

  Future<void> removeSavedPassenger(String id) async {
    if (_currentUser == null) return;
    final currentList = List<Passenger>.from(_currentUser!.savedPassengers);
    currentList.removeWhere((p) => p.id == id);
    final updated = _currentUser!.copyWith(savedPassengers: currentList);
    _currentUser = updated;
    await LocalStorage.saveUser(updated);
    notifyListeners();
  }
}
