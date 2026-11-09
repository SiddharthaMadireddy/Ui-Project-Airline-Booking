import 'package:flutter/material.dart';
import '../data/local_storage.dart';
import '../models/booking.dart';
import '../models/fare.dart';
import '../models/flight.dart';
import '../services/refund_service.dart';

/// Provider managing all bookings, PNR lookup, cancellations, rescheduling & web check-in
class TripsProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;

  TripsProvider() {
    loadBookings();
  }

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  List<Booking> get upcomingBookings => _bookings
      .where(
        (b) =>
            b.status == BookingStatus.confirmed &&
            b.flight.departureTime.isAfter(DateTime.now()),
      )
      .toList();

  List<Booking> get completedBookings => _bookings
      .where(
        (b) =>
            b.status == BookingStatus.completed ||
            (b.status == BookingStatus.confirmed &&
                b.flight.departureTime.isBefore(DateTime.now())),
      )
      .toList();

  List<Booking> get cancelledBookings =>
      _bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  void loadBookings() {
    _isLoading = true;
    _bookings = LocalStorage.getBookings();
    _isLoading = false;
    notifyListeners();
  }

  /// Lookup booking by PNR and Last Name
  Booking? lookupByPnrAndLastName(String pnr, String lastName) {
    final cleanPnr = pnr.trim().toUpperCase();
    final cleanLast = lastName.trim().toLowerCase();

    for (final b in _bookings) {
      if (b.pnr.toUpperCase() == cleanPnr) {
        // Match primary or any passenger's last name
        final match = b.passengers.any(
          (p) => p.lastName.trim().toLowerCase() == cleanLast,
        );
        if (match || cleanLast.isEmpty) {
          return b;
        }
      }
    }
    return null;
  }

  /// Cancel booking with calculated refund
  Future<RefundCalculationResult> cancelBooking(String pnr) async {
    final idx = _bookings.indexWhere((b) => b.pnr == pnr);
    if (idx == -1) {
      throw Exception('Booking not found');
    }

    final booking = _bookings[idx];
    final result = RefundService.calculateCancellationRefund(booking);

    final updated = booking.copyWith(
      status: BookingStatus.cancelled,
      refundAmount: result.totalRefund,
      cancellationDate: DateTime.now(),
    );

    _bookings[idx] = updated;
    await LocalStorage.updateBooking(updated);
    notifyListeners();
    return result;
  }

  /// Reschedule booking to a new flight
  Future<void> rescheduleBooking({
    required String pnr,
    required Flight newFlight,
    required FareOption newFare,
  }) async {
    final idx = _bookings.indexWhere((b) => b.pnr == pnr);
    if (idx == -1) return;

    final booking = _bookings[idx];
    final updated = booking.copyWith(
      flight: newFlight,
      fareFamily: newFare.name,
    );

    _bookings[idx] = updated;
    await LocalStorage.updateBooking(updated);
    notifyListeners();
  }

  /// Check-in eligibility check: Departure between 2h and 48h from now
  static bool isEligibleForCheckIn(DateTime departureTime) {
    final now = DateTime.now();
    final diff = departureTime.difference(now);
    // 2 hours to 48 hours
    return diff.inMinutes >= 120 && diff.inHours <= 48;
  }

  /// Perform Web Check-in: confirms seats and creates boarding passes
  Future<Booking> checkIn({
    required String pnr,
    required Map<String, String> passengerSeats,
  }) async {
    final idx = _bookings.indexWhere((b) => b.pnr == pnr);
    if (idx == -1) {
      throw Exception('Booking not found');
    }

    final booking = _bookings[idx];
    final departure = booking.flight.departureTime;
    final boardingTime = departure.subtract(const Duration(minutes: 45));

    final List<BoardingPassData> boardingPasses = [];
    final updatedPassengers = booking.passengers.map((p) {
      final seat = passengerSeats[p.id] ?? p.seatNumber ?? '14A';
      final pass = BoardingPassData(
        passengerName: p.fullName,
        pnr: booking.pnr,
        flightNumber: booking.flight.flightNumber,
        seat: seat,
        boardingGroup: booking.fareFamily.contains('Business')
            ? 'Group 1'
            : 'Group 3',
        gate: 'Gate ${12 + (booking.pnr.hashCode % 18).abs()}',
        boardingTime: boardingTime,
        originCode: booking.flight.origin.code,
        destinationCode: booking.flight.destination.code,
        terminal: booking.flight.origin.code == 'DEL' ? 'T3' : 'T2',
      );
      boardingPasses.add(pass);
      return p.copyWith(seatNumber: seat);
    }).toList();

    final updated = booking.copyWith(
      isCheckedIn: true,
      passengers: updatedPassengers,
      boardingPasses: boardingPasses,
    );

    _bookings[idx] = updated;
    await LocalStorage.updateBooking(updated);
    notifyListeners();
    return updated;
  }

  /// Reset all demo bookings
  Future<void> resetDemoData() async {
    await LocalStorage.resetDemoData();
    loadBookings();
  }
}
