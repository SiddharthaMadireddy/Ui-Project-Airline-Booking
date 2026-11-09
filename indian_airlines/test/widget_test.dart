import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indian_airlines/app.dart';
import 'package:indian_airlines/data/airports.dart';
import 'package:indian_airlines/data/local_storage.dart';
import 'package:indian_airlines/providers/search_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
  });

  testWidgets('App renders splash and transitions cleanly to Home', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const IndianAirlinesApp());
    expect(find.byType(MaterialApp), findsOneWidget);

    // Pump past the 1.5s splash animation
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));

    expect(find.text('Book Flight'), findsWidgets);
    expect(find.text('Manage Booking'), findsWidgets);
    expect(find.text('Exclusive Deals & Offers'), findsOneWidget);
    expect(find.text('Book Nonstop Direct Flights'), findsOneWidget);
  });

  testWidgets('Search Provider validates same origin and destination', (
    WidgetTester tester,
  ) async {
    final search = SearchProvider();
    final del = AirportData.findByCode('DEL')!;

    search.setOrigin(del);
    search.setDestination(del);

    final error = search.validateSearch();
    expect(error, equals('Origin and destination cannot be the same airport'));
  });

  testWidgets(
    'Verify no RenderFlex overflow across 4 standard widths (360, 768, 1280, 1920)',
    (WidgetTester tester) async {
      final widths = [360.0, 768.0, 1280.0, 1920.0];

      for (final width in widths) {
        tester.view.physicalSize = Size(width, 1000.0);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const IndianAirlinesApp());
        await tester.pumpAndSettle(const Duration(milliseconds: 2000));

        // Finding Indian Airlines branding without throwing overflow exceptions
        expect(find.byType(MaterialApp), findsOneWidget);
      }

      tester.view.resetPhysicalSize();
    },
  );
}
