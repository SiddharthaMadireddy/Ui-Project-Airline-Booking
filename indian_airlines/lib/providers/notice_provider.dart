import 'package:flutter/material.dart';

class NoticeItem {
  final String id;
  final String message;
  final String type; // advisory, info, promo

  const NoticeItem({
    required this.id,
    required this.message,
    this.type = 'advisory',
  });
}

/// Provider managing top dismissible travel advisory ticker
class NoticeProvider extends ChangeNotifier {
  final List<NoticeItem> _notices = const [
    NoticeItem(
      id: 'adv_1',
      message:
          'Winter Fog Advisory: Early morning schedules at Delhi (DEL) and Amritsar (ATQ) may experience minor delays.',
      type: 'advisory',
    ),
    NoticeItem(
      id: 'adv_2',
      message:
          'DGCA Safety Notice: Power banks & spare lithium batteries must strictly be carried in cabin baggage only.',
      type: 'info',
    ),
    NoticeItem(
      id: 'adv_3',
      message:
          'New Non-Stop Route: Introducing direct flights between Bengaluru (BLR) and London Heathrow (LHR)!',
      type: 'promo',
    ),
    NoticeItem(
      id: 'adv_4',
      message:
          'Web Check-in is mandatory and opens 48 hours prior to flight departure. Avoid airport queues.',
      type: 'info',
    ),
  ];

  int _currentIndex = 0;
  bool _isDismissed = false;

  bool get isDismissed => _isDismissed;
  int get currentIndex => _currentIndex;

  NoticeItem? get currentNotice {
    if (_isDismissed || _notices.isEmpty) return null;
    return _notices[_currentIndex % _notices.length];
  }

  void nextNotice() {
    if (_notices.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _notices.length;
      notifyListeners();
    }
  }

  void dismiss() {
    _isDismissed = true;
    notifyListeners();
  }

  void restore() {
    _isDismissed = false;
    notifyListeners();
  }
}
