import 'package:flutter/material.dart';
import '../data/airports.dart';
import '../data/flight_generator.dart';
import '../models/airport.dart';
import '../models/fare.dart';
import '../models/flight.dart';
import '../models/search_query.dart';

/// Provider managing flight search criteria, filters, results and selection
class SearchProvider extends ChangeNotifier {
  SearchQuery _query = SearchQuery(
    origin: AirportData.findByCode('DEL'),
    destination: AirportData.findByCode('BOM'),
    departureDate: DateTime.now().add(const Duration(days: 3)),
  );

  bool _isSearching = false;
  List<Flight> _rawOutboundFlights = [];
  List<Flight> _rawReturnFlights = [];
  Map<DateTime, double> _dailyLowestFares = {};

  // Filter states
  Set<int> _selectedStops = {0, 1}; // 0 = nonstop, 1 = 1 stop
  Set<String> _selectedTimeSlots = {
    'early',
    'morning',
    'afternoon',
    'night',
  };
  double _minPrice = 0.0;
  double _maxPrice = 50000.0;
  RangeValues _priceRange = const RangeValues(0, 50000);
  String _sortBy = 'cheapest'; // 'cheapest', 'fastest', 'earliest'

  // Selection states
  Flight? _selectedOutboundFlight;
  Flight? _selectedReturnFlight;
  FareOption? _selectedFareOption;

  SearchQuery get query => _query;
  bool get isSearching => _isSearching;
  Map<DateTime, double> get dailyLowestFares => _dailyLowestFares;
  Set<int> get selectedStops => _selectedStops;
  Set<String> get selectedTimeSlots => _selectedTimeSlots;
  RangeValues get priceRange => _priceRange;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get sortBy => _sortBy;
  Flight? get selectedOutboundFlight => _selectedOutboundFlight;
  Flight? get selectedReturnFlight => _selectedReturnFlight;
  FareOption? get selectedFareOption => _selectedFareOption;

  // --- Passenger Rules (max 9, infants <= adults) ---
  bool canAddAdult() => _query.totalPassengers < 9;
  bool canAddChild() => _query.totalPassengers < 9;
  bool canAddInfant() =>
      _query.totalPassengers < 9 && _query.infants < _query.adults;

  void updatePassengers({
    required int adults,
    required int children,
    required int infants,
  }) {
    if (adults < 1) adults = 1;
    if (adults + children + infants > 9) return;
    if (infants > adults) infants = adults;

    _query = _query.copyWith(
      adults: adults,
      children: children,
      infants: infants,
    );
    notifyListeners();
  }

  void setTripType(TripType type) {
    DateTime? retDate = _query.returnDate;
    if (type == TripType.roundTrip && retDate == null) {
      retDate = _query.departureDate.add(const Duration(days: 4));
    }
    _query = _query.copyWith(tripType: type, returnDate: retDate);
    notifyListeners();
  }

  void setOrigin(Airport? airport) {
    _query = _query.copyWith(origin: airport);
    notifyListeners();
  }

  void setDestination(Airport? airport) {
    _query = _query.copyWith(destination: airport);
    notifyListeners();
  }

  void swapOriginDestination() {
    final temp = _query.origin;
    _query = _query.copyWith(
      origin: _query.destination,
      destination: temp,
    );
    notifyListeners();
  }

  void setDepartureDate(DateTime date) {
    _query = _query.copyWith(departureDate: date);
    if (_query.returnDate != null && _query.returnDate!.isBefore(date)) {
      _query = _query.copyWith(returnDate: date.add(const Duration(days: 3)));
    }
    notifyListeners();
  }

  void setReturnDate(DateTime? date) {
    _query = _query.copyWith(returnDate: date);
    notifyListeners();
  }

  void setTravelClass(String travelClass) {
    _query = _query.copyWith(travelClass: travelClass);
    notifyListeners();
  }

  void setFareType(String fareType) {
    _query = _query.copyWith(fareType: fareType);
    notifyListeners();
  }

  void setPromoCode(String? code) {
    _query = _query.copyWith(promoCode: code);
    notifyListeners();
  }

  /// Validation: Origin != Destination, valid airports
  String? validateSearch() {
    if (_query.origin == null) return 'Please select departure airport';
    if (_query.destination == null) return 'Please select destination airport';
    if (_query.origin!.code == _query.destination!.code) {
      return 'Origin and destination cannot be the same airport';
    }
    if (_query.tripType == TripType.roundTrip && _query.returnDate == null) {
      return 'Please select a return date';
    }
    return null;
  }

  /// Execute search with simulated delay for skeleton loading demo
  Future<void> searchFlights() async {
    final err = validateSearch();
    if (err != null) return;

    _isSearching = true;
    _selectedOutboundFlight = null;
    _selectedReturnFlight = null;
    _selectedFareOption = null;
    notifyListeners();

    // 1-second simulated delay to demonstrate skeleton loading state cleanly
    await Future.delayed(const Duration(milliseconds: 900));

    final outbound = FlightGenerator.generate(
      origin: _query.origin!,
      destination: _query.destination!,
      date: _query.departureDate,
    );

    _rawOutboundFlights = outbound;

    if (_query.tripType == TripType.roundTrip && _query.returnDate != null) {
      _rawReturnFlights = FlightGenerator.generate(
        origin: _query.destination!,
        destination: _query.origin!,
        date: _query.returnDate!,
      );
    } else {
      _rawReturnFlights = [];
    }

    // Generate 7-day strip
    _dailyLowestFares = FlightGenerator.generate7DayFares(
      origin: _query.origin!,
      destination: _query.destination!,
      centerDate: _query.departureDate,
    );

    // Initialize price range slider boundaries
    if (outbound.isNotEmpty) {
      final prices = outbound.map((f) => f.basePrice).toList();
      _minPrice = prices.reduce((a, b) => a < b ? a : b);
      _maxPrice = prices.reduce((a, b) => a > b ? a : b);
      _priceRange = RangeValues(_minPrice, _maxPrice);
    }

    _isSearching = false;
    notifyListeners();
  }

  // --- Filtering & Sorting ---
  void toggleStop(int stop) {
    if (_selectedStops.contains(stop)) {
      if (_selectedStops.length > 1) {
        _selectedStops.remove(stop);
      }
    } else {
      _selectedStops.add(stop);
    }
    notifyListeners();
  }

  void toggleTimeSlot(String slot) {
    if (_selectedTimeSlots.contains(slot)) {
      if (_selectedTimeSlots.length > 1) {
        _selectedTimeSlots.remove(slot);
      }
    } else {
      _selectedTimeSlots.add(slot);
    }
    notifyListeners();
  }

  void setPriceRange(RangeValues values) {
    _priceRange = values;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  List<Flight> get filteredOutboundFlights {
    var list = _rawOutboundFlights.where((f) {
      // 1. Stops filter
      if (!_selectedStops.contains(f.stops)) return false;

      // 2. Departure time slot
      final hour = f.departureTime.hour;
      bool matchesTime = false;
      if (hour >= 4 && hour < 8 && _selectedTimeSlots.contains('early')) {
        matchesTime = true;
      } else if (hour >= 8 && hour < 12 && _selectedTimeSlots.contains('morning')) {
        matchesTime = true;
      } else if (hour >= 12 && hour < 18 && _selectedTimeSlots.contains('afternoon')) {
        matchesTime = true;
      } else if ((hour >= 18 || hour < 4) && _selectedTimeSlots.contains('night')) {
        matchesTime = true;
      }
      if (!matchesTime) return false;

      // 3. Price range
      if (f.basePrice < _priceRange.start || f.basePrice > _priceRange.end) {
        return false;
      }

      return true;
    }).toList();

    // 4. Sorting
    if (_sortBy == 'cheapest') {
      list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (_sortBy == 'fastest') {
      list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
    } else if (_sortBy == 'earliest') {
      list.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }

    return list;
  }

  List<Flight> get filteredReturnFlights => _rawReturnFlights;

  void selectOutboundFlight(Flight flight, FareOption fare) {
    _selectedOutboundFlight = flight;
    _selectedFareOption = fare;
    notifyListeners();
  }

  void selectReturnFlight(Flight flight) {
    _selectedReturnFlight = flight;
    notifyListeners();
  }

  void resetFilters() {
    _selectedStops = {0, 1};
    _selectedTimeSlots = {'early', 'morning', 'afternoon', 'night'};
    _priceRange = RangeValues(_minPrice, _maxPrice);
    _sortBy = 'cheapest';
    notifyListeners();
  }
}
