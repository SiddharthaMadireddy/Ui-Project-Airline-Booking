import 'dart:async';
import 'package:flutter/material.dart';
import '../data/local_storage.dart';
import '../data/offers.dart';
import '../models/booking.dart';
import '../models/fare.dart';
import '../models/flight.dart';
import '../models/offer.dart';
import '../models/passenger.dart';
import '../services/pnr_generator.dart';
import '../services/pricing_service.dart';

/// Provider managing multi-step booking state, add-ons, countdown timer & checkout
class BookingProvider extends ChangeNotifier {
  int _currentStep = 0; // 0 to 4

  Flight? _flight;
  Flight? _returnFlight;
  FareOption? _fareOption;
  String _fareType = 'Regular';

  List<Passenger> _passengers = [];
  bool _hasInsurance = false;
  bool _hasPriorityBoarding = false;
  Offer? _appliedOffer;
  bool _redeemPoints = false;
  int _pointsToRedeem = 0;

  // Contact details
  String _contactEmail = '';
  String _contactPhone = '';
  String _gstNumber = '';
  String _companyName = '';
  bool _isGstEnabled = false;

  // Payment form state
  String _paymentMethod = 'UPI'; // UPI, Card, Net Banking, Wallet
  String _upiId = '';
  String _cardNumber = '';
  String _cardExpiry = '';
  String _cardCvv = '';
  String _cardHolderName = '';
  String _selectedBank = 'State Bank of India';
  String _selectedWallet = 'Paytm Wallet';

  // Countdown timer for booking session (10 minutes = 600s)
  int _secondsRemaining = 600;
  Timer? _sessionTimer;
  bool _isSessionExpired = false;

  // Processing & Confirmation
  bool _isPaymentProcessing = false;
  Booking? _confirmedBooking;

  // Getters
  int get currentStep => _currentStep;
  Flight? get flight => _flight;
  Flight? get returnFlight => _returnFlight;
  FareOption? get fareOption => _fareOption;
  String get fareType => _fareType;
  List<Passenger> get passengers => _passengers;
  bool get hasInsurance => _hasInsurance;
  bool get hasPriorityBoarding => _hasPriorityBoarding;
  Offer? get appliedOffer => _appliedOffer;
  bool get redeemPoints => _redeemPoints;
  int get pointsToRedeem => _pointsToRedeem;
  String get contactEmail => _contactEmail;
  String get contactPhone => _contactPhone;
  String get gstNumber => _gstNumber;
  String get companyName => _companyName;
  bool get isGstEnabled => _isGstEnabled;
  String get paymentMethod => _paymentMethod;
  String get upiId => _upiId;
  String get cardNumber => _cardNumber;
  String get cardExpiry => _cardExpiry;
  String get cardCvv => _cardCvv;
  String get cardHolderName => _cardHolderName;
  String get selectedBank => _selectedBank;
  String get selectedWallet => _selectedWallet;
  int get secondsRemaining => _secondsRemaining;
  bool get isSessionExpired => _isSessionExpired;
  bool get isPaymentProcessing => _isPaymentProcessing;
  Booking? get confirmedBooking => _confirmedBooking;

  String get formattedTimer {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void initializeBooking({
    required Flight flight,
    Flight? returnFlight,
    required FareOption fareOption,
    required int adults,
    required int children,
    required int infants,
    required String fareType,
    String? promoCode,
  }) {
    _flight = flight;
    _returnFlight = returnFlight;
    _fareOption = fareOption;
    _fareType = fareType;
    _currentStep = 0;
    _confirmedBooking = null;
    _isSessionExpired = false;
    _secondsRemaining = 600;
    _hasInsurance = false;
    _hasPriorityBoarding = false;
    _redeemPoints = false;
    _pointsToRedeem = 0;

    // Apply promo code if present
    if (promoCode != null && promoCode.isNotEmpty) {
      _appliedOffer = OffersData.findByCode(promoCode);
    } else {
      _appliedOffer = null;
    }

    // Auto-fill logged-in user contact info
    final currentUser = LocalStorage.getUser();
    if (currentUser != null) {
      _contactEmail = currentUser.email;
      _contactPhone = currentUser.phone;
    }

    // Initialize blank passenger objects
    _passengers = [];
    int pIndex = 1;

    for (int i = 0; i < adults; i++) {
      // Pre-fill primary passenger from logged in profile if available
      final isFirst = (i == 0);
      _passengers.add(
        Passenger(
          id: 'p_${pIndex++}',
          title: isFirst ? 'Mr' : 'Ms',
          firstName: isFirst && currentUser != null
              ? currentUser.name.split(' ').first
              : '',
          lastName: isFirst &&
                  currentUser != null &&
                  currentUser.name.split(' ').length > 1
              ? currentUser.name.split(' ').sublist(1).join(' ')
              : '',
          type: 'Adult',
          gender: isFirst ? 'Male' : 'Female',
          nationality: 'Indian',
        ),
      );
    }

    for (int i = 0; i < children; i++) {
      _passengers.add(
        Passenger(
          id: 'p_${pIndex++}',
          title: 'Master',
          firstName: '',
          lastName: '',
          type: 'Child',
          gender: 'Male',
          nationality: 'Indian',
        ),
      );
    }

    for (int i = 0; i < infants; i++) {
      _passengers.add(
        Passenger(
          id: 'p_${pIndex++}',
          title: 'Master',
          firstName: '',
          lastName: '',
          type: 'Infant',
          gender: 'Male',
          nationality: 'Indian',
        ),
      );
    }

    startTimer();
    notifyListeners();
  }

  void startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _isSessionExpired = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void setStep(int step) {
    if (step >= 0 && step <= 4) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // --- Passenger Details Updates ---
  void updatePassenger(int index, Passenger updated) {
    if (index >= 0 && index < _passengers.length) {
      _passengers[index] = updated;
      notifyListeners();
    }
  }

  void setContactDetails({
    required String email,
    required String phone,
    bool? isGstEnabled,
    String? gstNumber,
    String? companyName,
  }) {
    _contactEmail = email;
    _contactPhone = phone;
    if (isGstEnabled != null) _isGstEnabled = isGstEnabled;
    if (gstNumber != null) _gstNumber = gstNumber;
    if (companyName != null) _companyName = companyName;
    notifyListeners();
  }

  // --- Add-on selections ---
  void selectSeat(String passengerId, String seatCode) {
    final idx = _passengers.indexWhere((p) => p.id == passengerId);
    if (idx != -1) {
      // If seat already assigned to another passenger, clear it
      for (int i = 0; i < _passengers.length; i++) {
        if (_passengers[i].seatNumber == seatCode) {
          _passengers[i] = _passengers[i].copyWith(seatNumber: '');
        }
      }
      _passengers[idx] = _passengers[idx].copyWith(seatNumber: seatCode);
      notifyListeners();
    }
  }

  void selectMeal(String passengerId, String meal) {
    final idx = _passengers.indexWhere((p) => p.id == passengerId);
    if (idx != -1) {
      _passengers[idx] = _passengers[idx].copyWith(mealPreference: meal);
      notifyListeners();
    }
  }

  void selectExtraBaggage(String passengerId, int kg) {
    final idx = _passengers.indexWhere((p) => p.id == passengerId);
    if (idx != -1) {
      _passengers[idx] = _passengers[idx].copyWith(extraBaggageKg: kg);
      notifyListeners();
    }
  }

  void toggleInsurance(bool value) {
    _hasInsurance = value;
    notifyListeners();
  }

  void togglePriorityBoarding(bool value) {
    _hasPriorityBoarding = value;
    notifyListeners();
  }

  void applyOffer(Offer? offer) {
    _appliedOffer = offer;
    notifyListeners();
  }

  void toggleRedeemPoints(bool value, int maxPointsAvailable) {
    _redeemPoints = value;
    _pointsToRedeem = value ? maxPointsAvailable : 0;
    notifyListeners();
  }

  // --- Payment form updates ---
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setUpiId(String id) {
    _upiId = id;
    notifyListeners();
  }

  void setCardDetails({
    required String number,
    required String expiry,
    required String cvv,
    required String holder,
  }) {
    _cardNumber = number;
    _cardExpiry = expiry;
    _cardCvv = cvv;
    _cardHolderName = holder;
    notifyListeners();
  }

  void setBank(String bank) {
    _selectedBank = bank;
    notifyListeners();
  }

  void setWallet(String wallet) {
    _selectedWallet = wallet;
    notifyListeners();
  }

  // --- Pricing Calculation ---
  PricingBreakdown get currentPricing {
    if (_flight == null || _fareOption == null) {
      return const PricingBreakdown(
        baseFare: 0,
        taxesAndFees: 0,
        fuelSurcharge: 0,
        convenienceFee: 0,
        grandTotal: 0,
      );
    }

    return PricingService.calculate(
      flight: _flight!,
      returnFlight: _returnFlight,
      fareOption: _fareOption!,
      passengers: _passengers,
      fareType: _fareType,
      appliedOffer: _appliedOffer,
      hasInsurance: _hasInsurance,
      hasPriorityBoarding: _hasPriorityBoarding,
      pointsToRedeem: _redeemPoints ? _pointsToRedeem : 0,
    );
  }

  /// Process mock payment and generate confirmed booking with 6-char PNR
  Future<bool> processPayment() async {
    _isPaymentProcessing = true;
    notifyListeners();

    // 1.5s simulated network payment processing
    await Future.delayed(const Duration(milliseconds: 1500));

    final String generatedPnr = PnrGenerator.generate();
    final pricing = currentPricing;

    final booking = Booking(
      pnr: generatedPnr,
      flight: _flight!,
      returnFlight: _returnFlight,
      passengers: List.from(_passengers),
      fareFamily: _fareOption!.name,
      travelClass: _flight!.origin.isDomestic ? 'Economy' : 'International Economy',
      status: BookingStatus.confirmed,
      bookingDate: DateTime.now(),
      contactEmail: _contactEmail,
      contactPhone: _contactPhone,
      gstNumber: _isGstEnabled ? _gstNumber : null,
      companyName: _isGstEnabled ? _companyName : null,
      hasInsurance: _hasInsurance,
      hasPriorityBoarding: _hasPriorityBoarding,
      pricing: pricing,
      paymentMethod: _paymentMethod,
      isCheckedIn: false,
    );

    // Save to local storage
    await LocalStorage.addBooking(booking);

    _sessionTimer?.cancel();
    _confirmedBooking = booking;
    _isPaymentProcessing = false;
    _currentStep = 4; // Step 5: Confirmation
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
