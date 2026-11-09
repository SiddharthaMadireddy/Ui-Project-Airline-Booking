# 🎓 Indian Airlines — Final-Year Viva Examination & Architecture Guide

> **Project:** Indian Airlines — Responsive Flight Booking Web Application  
> **Target Platform:** Flutter Web (Deployed to GitHub Pages)  
> **Course:** UI & Mobile Computing Lab / Software Engineering Capstone  

---

## 📑 Table of Contents
1. [Architecture & Design Decisions](#1-architecture--design-decisions)
2. [User Journey Flow](#2-user-journey-flow)
3. [Lab Syllabus Concept Mapping](#3-lab-syllabus-concept-mapping)
4. [Algorithmic Highlights](#4-algorithmic-highlights)
5. [30 Essential Viva Questions & Answers](#5-30-essential-viva-questions--answers)
6. [Future Enhancements](#6-future-enhancements)

---

## 1. Architecture & Design Decisions

### Layered Separation of Concerns
The application follows a clean, decoupled architecture:

```
lib/
├── core/         # Cross-cutting concerns: constants, theme, responsive helpers, validators, routes
├── data/         # Static datasets, seed data, deterministic generators, local storage adapter
├── models/       # Immutable data structures with copyWith and JSON serialization
├── providers/    # Business logic & state holders extending ChangeNotifier (Provider pattern)
├── services/     # Pure functional domain engines: pricing, refunds, seat map, PNR generation
├── screens/      # Feature screens (views) observing providers
└── widgets/      # Reusable UI components & CustomPainters (logo, nav, seat map, e-ticket)
```

### Why Flutter Web?
1. **Single Unified Codebase:** Compiles natively to Web (CanvasKit/HTML renderer) and can easily target Android/iOS/Desktop without rewriting.
2. **Declarative UI:** The reactive UI paradigm allows easy state synchronization between the booking stepper, seat map, and pricing sidebar.
3. **No External Backend Needed for Lab Evaluation:** By combining deterministic seed generation with `shared_preferences` persistence in the browser's IndexedDB / LocalStorage, the application behaves as a full-fledged enterprise app without server maintenance or API quotas.

---

## 2. User Journey Flow

```
[ Splash Screen (1.5s Flight Animation) ]
                  │
                  ▼
          [ Home Screen ]
    ┌─────────────┼──────────────┬──────────────┐
    ▼             ▼              ▼              ▼
[Search Flights] [Manage PNR] [Web Check-in] [Flight Status]
    │             │              │              │
    ▼             ▼              │              ▼
[Results Grid]  [Reschedule/     │        [Status Timeline]
    │           Cancel & Refund] │
    ▼                            │
[Booking Stepper (5 Steps)]      │
 1. Itinerary Review             │
 2. Passenger Details Form       │
 3. Seat Map & Add-ons           │
 4. Mock Payment (Luhn + 10m)    │
 5. E-Ticket & Custom QR ────────┼──────────────┐
                                 │              │
                                 ▼              ▼
                       [Web Check-in Flow] [Saved Trips]
                       (48h-2h window check)
                                 │
                                 ▼
                       [Boarding Pass View]
                       (Custom Barcode + Gate)
```

---

## 3. Lab Syllabus Concept Mapping

| Flutter / Dart Concept | Where Used in Codebase | Explanation for Viva |
| :--- | :--- | :--- |
| **State Management** | `lib/providers/` (`SearchProvider`, `BookingProvider`, `TripsProvider`, `LoyaltyProvider`, etc.) | Utilizes `ChangeNotifier` with `MultiProvider` to propagate state changes without tight coupling. |
| **Responsive Layout** | `lib/core/responsive.dart`, `ResponsiveContainer`, `LayoutBuilder` | Detects viewport width breakpoints (`<600px` mobile, `600–1024px` tablet, `>1024px` desktop) to switch between TopNav and Drawer, grid columns, and sidebars. |
| **Custom Graphics** | `lib/widgets/app_logo.dart`, `boarding_pass.dart`, `eticket_view.dart`, `route_painter.dart` | Employs `CustomPainter` to draw the 24-spoke chakra, airline soaring wings, barcodes, pseudo-QR codes, and quadratic bezier flight curves. |
| **Forms & Validation** | `lib/core/validators.dart`, `booking_screen.dart`, `auth_screen.dart`, `search_widget.dart` | Form keys, controllers, real-time validators (Luhn algorithm for credit cards, regex for email, phone, PNR). |
| **Animation Controllers** | `splash_screen.dart`, `search_widget.dart` (Swap button) | Explicit `AnimationController` for smooth translation and 180° rotation transforms. |
| **Deterministic Data** | `lib/data/flight_generator.dart` | Generates identical, realistic flight lists for any given origin, destination, and departure date using a stable hash. |
| **Persistence** | `lib/data/local_storage.dart` | Uses `shared_preferences` for browser storage of bookings, frequent flyers, and dark mode preferences. |
| **Theming (Material 3)** | `lib/core/theme.dart`, `lib/providers/theme_provider.dart` | Full Light and Dark mode support with customized color schemes, typography, and card themes. |
| **Automated Testing** | `test/unit/`, `test/widget_test.dart` | Comprehensive test suite covering pricing algorithms, refund policies, Luhn validator, and 4-width responsive overflow checks. |

---

## 4. Algorithmic Highlights

### A. Credit Card Luhn Algorithm (`lib/core/validators.dart`)
Validates credit card checksum in $O(n)$ time:
1. Double every second digit from right to left.
2. If doubling yields a number $> 9$, subtract $9$.
3. Sum all resulting digits.
4. If `sum % 10 == 0`, the card number is mathematically valid.

### B. Tiered Cancellation Refund Engine (`lib/services/refund_service.dart`)
- **$> 24$ hours to departure:** Returns $80\%$ of base fare + $100\%$ of statutory taxes (UDF, GST) minus cancellation fee.
- **$2$ to $24$ hours to departure:** Returns $50\%$ of base fare + $100\%$ of statutory taxes minus cancellation fee.
- **$< 2$ hours to departure:** No base fare refund (considered no-show); statutory airport taxes refunded.
- **Economy Flex Tier:** Waives the standard cancellation fee entirely.

### C. Web Check-in Eligibility Window (`lib/models/booking.dart`)
```dart
bool get isCheckInEligible {
  final now = DateTime.now();
  final difference = flight.departureTime.difference(now);
  return difference.inHours <= 48 && difference.inHours >= 2 && status == BookingStatus.confirmed;
}
```

---

## 5. 30 Essential Viva Questions & Answers

### General & Architecture
#### Q1: What is the main objective of this project?
**Answer:** To build a production-grade, responsive flight booking web application in Flutter demonstrating key front-end software engineering principles: state management, responsive UI, form validation, client-side persistence, algorithms, and automated testing without relying on third-party backend servers.

#### Q2: Why did you choose Provider over Bloc, Riverpod, or GetX?
**Answer:** `Provider` is the officially recommended, lightweight state management solution maintained by the Flutter community. It relies on Flutter's native `InheritedWidget` mechanism and `ChangeNotifier`. It offers a clean separation of concerns without the boilerplate of Bloc or the complexity of Riverpod, making the codebase highly maintainable and easy to explain.

#### Q3: How is state shared between screens?
**Answer:** At the root of the widget tree in `lib/main.dart`, `MultiProvider` registers all global providers (`ThemeProvider`, `SearchProvider`, `BookingProvider`, `TripsProvider`, `LoyaltyProvider`, `AuthProvider`, `NoticeProvider`). Child widgets access them via `context.watch<T>()` for reactive rebuilding or `context.read<T>()` for one-time event dispatching.

#### Q4: Why did you not use external network images?
**Answer:** In Flutter Web, loading third-party images often triggers CORS (Cross-Origin Resource Sharing) restrictions or slow image flickers. To ensure 100% offline-ready and glitch-free rendering, all visuals are constructed using Flutter's `CustomPainter`, vector icons, linear gradients, and SVG paths.

---

### UI & Responsiveness
#### Q5: How does the application achieve responsive layout across mobile and desktop?
**Answer:** We created a helper class `Responsive` (`lib/core/responsive.dart`) that inspects `MediaQuery.of(context).size.width` against established breakpoints:
- **Mobile:** $< 600\text{ px}$
- **Tablet:** $600\text{ px} - 1024\text{ px}$
- **Desktop:** $> 1024\text{ px}$
Additionally, `ResponsiveContainer` constrains the maximum content width to $1200\text{ px}$ on ultra-wide screens for optimal readability.

#### Q6: How do you prevent RenderFlex overflow errors on small screens?
**Answer:** By wrapping potentially overflowing rows in `Wrap`, `Flexible`, or `Expanded`, using `SingleChildScrollView` for scrollable sections, and wrapping fixed-size vector logos in `FittedBox(fit: BoxFit.scaleDown)`.

#### Q7: How does the navigation bar adapt between desktop and mobile?
**Answer:** In `lib/widgets/top_nav.dart`, desktop view displays horizontal navigation menus with popup actions, while mobile view replaces them with a standard hamburger icon that opens a navigation `Drawer` (`lib/widgets/app_drawer.dart`).

---

### State Management & Data
#### Q8: What is the difference between `context.watch<T>()` and `context.read<T>()`?
**Answer:** `context.watch<T>()` subscribes the widget to listen for updates; whenever `notifyListeners()` is invoked in the provider, the widget rebuilds. `context.read<T>()` returns the provider instance without listening, making it ideal for event callbacks such as `onPressed` to prevent unnecessary widget rebuilds.

#### Q9: How is persistent data handled without a backend database?
**Answer:** In `lib/data/local_storage.dart`, we serialize Dart model objects (`Booking`, `User`, `SearchQuery`) to JSON strings and store them using `shared_preferences`. On the web, `shared_preferences` maps directly to the browser's `localStorage` or `IndexedDB`.

#### Q10: How does the flight generator produce realistic flights deterministically?
**Answer:** In `lib/data/flight_generator.dart`, a hash code is computed from `originCode + destinationCode + date`. This integer acts as the seed for a `Random(seed)` generator, ensuring that searching for the same route and date always returns the exact same flight numbers, timings, and aircraft types.

---

### Booking & Business Logic
#### Q11: What passenger constraints are enforced in the booking engine?
**Answer:**
1. Total passengers across all categories cannot exceed $9$.
2. At least one adult passenger must accompany an infant (i.e., `infants <= adults`).
3. Origin and destination airports cannot be identical.

#### Q12: How are airfares and taxes calculated?
**Answer:** In `lib/services/pricing_service.dart`:
- Total Base Fare = Base price per passenger type (Adult $= 1.0\times$, Child $= 0.75\times$, Infant $= 0.1\times$) $\times$ Cabin multiplier (Saver $= 1.0\times$, Flex $= 1.2\times$, Business $= 2.2\times$).
- Fuel Surcharge: ₹850 per ticket.
- Airport UDF (User Development Fee): ₹450.
- GST: 5% on Economy, 12% on Business.
- Total = Base Fare + Taxes + Add-ons (Seats, Meals, Baggage) $-$ Promo Discount.

#### Q13: What happens when a passenger cancels a booking?
**Answer:** `RefundService.calculateCancellationRefund()` checks the departure datetime against `DateTime.now()`. If cancelled $>24$ hours prior, $80\%$ of base fare is refunded plus all statutory taxes. The booking status updates to `BookingStatus.cancelled` and is saved to `localStorage`.

#### Q14: How does the 10-minute payment countdown timer work?
**Answer:** In `booking_screen.dart`, a `Timer.periodic(Duration(seconds: 1))` decrements the session time. If the timer reaches $00:00$, a session expiration dialog informs the user and resets the reservation to release the temporary seat hold.

---

### Graphics & CustomPainter
#### Q15: How did you implement the airline logo without image files?
**Answer:** In `lib/widgets/app_logo.dart`, an `AppLogoPainter` extends `CustomPainter`. It uses `Canvas.drawCircle` for the outer and inner gold rings, `Canvas.drawLine` with trigonometric polar calculations for the 24 spokes, and `Canvas.drawPath` with cubic bezier curves for the soaring bird wings.

#### Q16: How is the e-ticket QR code rendered?
**Answer:** In `lib/widgets/eticket_view.dart`, `PseudoQrPainter` deterministically generates a grid of dark and light modules based on the PNR string hash and draws standard QR positional corner markers using `canvas.drawRect`.

#### Q17: How is the flight route map drawn?
**Answer:** In `lib/widgets/route_painter.dart`, airport coordinates are mapped to canvas coordinates. Flight paths are rendered as curved lines using `path.quadraticBezierTo()` with an elevated control point to simulate great-circle flight arcs.

---

### Forms & Validation
#### Q18: What is the Luhn Algorithm and where is it applied?
**Answer:** It is a checksum formula used to validate credit card numbers against accidental typos. It is implemented in `lib/core/validators.dart` and called by the payment form.

#### Q19: How do you format credit card numbers as the user types?
**Answer:** Using a custom `TextInputFormatter` (`CardNumberFormatter`) that automatically inserts spaces after every 4 digits and limits the input to 16 digits.

#### Q20: How are promo codes verified?
**Answer:** The promo code entered in `SearchProvider` or `BookingProvider` is checked against the pre-seeded active offers list in `lib/data/offers.dart`. If valid, the corresponding percentage or flat discount is deducted from the base fare.

---

### Deployment & Web Specifics
#### Q21: What is the purpose of the `base-href` flag during web build?
**Answer:** For GitHub Pages, projects are served from a subpath (e.g., `https://username.github.io/repository-name/`). Specifying `--base-href "/repository-name/"` ensures that Flutter's asset loader, scripts, and router resolve URLs relative to the repository folder rather than the domain root.

#### Q22: Why is `web/404.html` required on GitHub Pages?
**Answer:** GitHub Pages is a static file host without URL rewriting. When a user refreshes a deep URL like `/search` or `/booking`, GitHub Pages serves a 404 error. `web/404.html` intercepts this and redirects back to `index.html` with query parameters, allowing Flutter's client-side router to handle deep links.

#### Q23: How does GitHub Actions automate deployment?
**Answer:** In `.github/workflows/deploy.yml`, an automated workflow triggers on push to `main`. It checks out the code, installs Flutter, runs `flutter analyze` and `flutter test`, builds the release web bundle, and pushes the output to the `gh-pages` branch.

---

### Testing & Verification
#### Q24: What kinds of tests are written in the project?
**Answer:**
1. **Unit Tests:** Verify business logic in isolation (Luhn validator, PNR generator, fare and tax calculations, cancellation refund tiers, check-in window rules).
2. **Widget Tests:** Verify UI rendering, splash-to-home navigation, search validation dialogs, and responsive layout without overflows across 4 screen widths ($360\text{ px}, 768\text{ px}, 1280\text{ px}, 1920\text{ px}$).

#### Q25: How do you run the tests?
**Answer:** By running the command:
```bash
flutter test
```

---

### Legal & Ethical Guidelines
#### Q26: Why is the disclaimer "Demo project: no real bookings or payments" displayed?
**Answer:** To comply with academic ethics, prevent misrepresentation as an actual commercial airline, and ensure evaluators understand that no financial transactions or API calls to airlines are made.

#### Q27: Did you copy any existing airline trademarks or assets?
**Answer:** No. Indian Airlines in this project is an entirely original concept with custom-designed vector branding, an original loyalty program ("Skyward Club"), and synthetic flight schedules.

---

### Viva Practical Scenarios
#### Q28: Can you demonstrate Web Check-in right now?
**Answer:** Yes. Enter PNR `IA7K9P` with Last Name `Sharma`. This pre-seeded flight departs in 18 hours, placing it squarely within the 48h–2h check-in window. It immediately opens passenger seat confirmation and generates a digital boarding pass with barcode and gate details.

#### Q29: Can you demonstrate a booking cancellation with refund calculation?
**Answer:** Yes. Enter PNR `IA3X2M` with Last Name `Patel` in Manage Booking. Because departure is more than 24 hours away, clicking "Cancel Flight" calculates an 80% base fare refund + 100% tax refund and updates the status to Cancelled.

#### Q30: How can a user swap the origin and destination airports?
**Answer:** In the search card, clicking the two-way arrow button triggers a 180° rotation animation while calling `searchProvider.swapAirports()`, instantly swapping the origin and destination fields with live validation.

---

## 6. Future Enhancements
1. **RESTful Backend Integration:** Connect to a Node.js/Go microservice with PostgreSQL database.
2. **Real Payment Gateways:** Integrate Razorpay or Stripe Web SDK in test mode.
3. **PWA (Progressive Web App):** Add Service Workers for full offline flight browsing and boarding pass offline wallet storage.
4. **Live Flight Tracking API:** Integrate AviationStack or FlightRadar24 API for live GPS flight telemetry.
