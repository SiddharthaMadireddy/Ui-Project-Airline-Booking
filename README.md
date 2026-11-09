# ✈️ Indian Airlines (Demo Flight Booking Web Application)

> **Final-Year External Lab Examination Project**  
> *A responsive, full-featured airline booking and flight management web application built entirely in Flutter.*

---

## ⚠️ Academic Disclaimer
**Indian Airlines** is a **fictional demonstration airline** created strictly for educational purposes and academic evaluation.  
- **No real bookings, transactions, or card charges are processed.**
- All branding, loyalty program ("Skyward Club"), flight schedules, and airline assets are 100% original.
- The prominent disclaimer `"Demo project: no real bookings or payments"` is displayed across the application footer and mock payment screens.

---

## 🌟 Core Features & Modules

### 1. 🛫 Flight Search & Booking Engine
- **Segmented Journey Types:** One-way, Round-trip, and Multi-city (2 legs).
- **Airport Autocomplete:** Fast lookup over **40 curated airports** (25 Indian domestic hubs + 15 global international destinations) with IATA codes, cities, and airport names.
- **Interactive Controls:** Animated origin/destination swap, Cupertino/Material date pickers, and passenger selector dialog (Adult, Child, Infant with validation rules: max 9 total, infants ≤ adults).
- **Fare Categories:** Regular, Student (10% discount), Senior Citizen (15% discount), and Armed Forces (20% discount).
- **Deterministic Flight Generator:** Dynamic, repeatable generation of 8–15 flights per route based on a deterministic hash of route + date.
- **Fare Families:** Economy Saver, Economy Flex (free cancellation & reschedule), and Business Class (premium baggage & seat).

### 2. 💺 Interactive Seat Selection
- Detailed SVG/Fuselage-style seat map with First Class (2x2), Extra Legroom, and Standard Economy (3x3).
- Real-time seat price calculation, passenger seat assignment switching, and occupied seat states.

### 3. 💳 Mock Payment Gateway & 10-Minute Timer
- Real-time **Luhn Algorithm** validation for credit/debit card numbers.
- Expiration date and 3/4-digit CVV checks with automatic card formatting.
- Alternative mock payment methods: UPI (Virtual Payment Address), Net Banking (top 8 Indian banks), and Digital Wallets.
- Live 10-minute session countdown timer simulating real airline booking holds.
- Full fare summary showing base fare, statutory UDF/taxes, fuel surcharge, and instant promo code discounts.

### 4. 🎫 Boarding Pass & E-Ticket Management
- **Instant E-Ticket generation** with generated 6-character alphanumeric PNR.
- Custom-drawn 2D pseudo-QR and barcode via Flutter `CustomPainter`.
- Downloadable text itinerary and one-tap clipboard sharing.

### 5. 🧳 Web Check-in (Strict Window Enforcement)
- Available strictly between **48 hours and 2 hours** prior to scheduled departure.
- Generates an official digital boarding pass with boarding group, gate, seat, and sequence number.
- **Pre-seeded demo booking:** PNR `IA7K9P` (LastName: `Sharma`) departs in 18 hours and is immediately eligible for check-in during viva demonstrations!

### 6. 🔁 Manage Booking, Cancellation & Rescheduling
- Instant lookup by PNR and Last Name.
- **Tiered Refund Engine:**
  - `> 24 hours` before departure: **80% Base Fare + 100% Taxes** minus standard cancellation fee.
  - `2 to 24 hours` before departure: **50% Base Fare + 100% Taxes** minus cancellation fee.
  - `< 2 hours` before departure: **0% Base Fare (No-show)**, statutory taxes refunded.
  - Instant wallet / source refund calculation displayed in confirmation dialog.
- Reschedule journey with real-time fare difference recalculation.

### 7. 🗺️ Where We Fly & Network Map
- Stylized flight network visualization drawn via Flutter `CustomPainter`.
- Searchable route table with domestic and international flight frequencies.

### 8. 🛡️ Skyward Club Loyalty Program
- Tier progression (Silver, Gold, Platinum).
- Interactive miles and points calculator based on route distance and cabin class.
- Points redemption toggle at checkout.

---

## 🛠️ Technology Stack & Architecture

- **Framework:** Flutter 3.44.x (Web & Desktop enabled)
- **Language:** Dart 3.12.x (100% Null-safe)
- **State Management:** `provider` (Clean `ChangeNotifier` pattern)
- **Persistence:** `shared_preferences` (Local storage for bookings, user profile, and checklists)
- **Internationalization:** `intl` (Indian Rupee `₹` formatting with `en_IN`)
- **Branding & Assets:** 100% vector-based with Flutter `CustomPainter` (Zero external network image dependencies)
- **Responsive Design:** Adaptive layout adapting seamlessly across mobile (<600px), tablet (600–1024px), and desktop (>1024px) screens.

---

## 🚀 How to Run Locally

### Prerequisites
- Flutter SDK installed (`flutter --version`)
- Google Chrome browser

### Quick Start
```bash
# 1. Clone or navigate to the project repository
cd indian_airlines

# 2. Get dependencies
flutter pub get

# 3. Run on Chrome
flutter run -d chrome
```

### Running Automated Tests
```bash
# Run all unit and widget tests
flutter test

# Verify clean code analysis
flutter analyze
```

---

## 🌐 Deploying to GitHub Pages

1. Push this repository to GitHub.
2. In your repository on GitHub, navigate to **Settings > Pages**.
3. Under **Build and deployment > Source**, select **GitHub Actions**.
4. The included `.github/workflows/deploy.yml` will automatically analyze, test, build, and deploy the application.
5. Alternatively, build manually for deployment:
```bash
flutter build web --release --base-href "/<YOUR-REPO-NAME>/"
```

---

## 🧪 Demo Data for Viva Examination

| Feature | PNR | Last Name | Status / Notes |
| :--- | :--- | :--- | :--- |
| **Web Check-in** | `IA7K9P` | `Sharma` | Eligible (Departs in 18 hrs, DEL → BOM) |
| **Cancellation / Refund** | `IA3X2M` | `Patel` | Business Class (>24h, high refund value) |
| **Completed Trip** | `IA9L1W` | `Verma` | History demo (Completed BLR → GOI) |

### Tested Promo Codes
- `STUDENT10` — 10% discount on base fare
- `FIRST5` — 5% discount on all bookings
- `FLYIND` — ₹500 flat discount
- `UPIPAY` — ₹200 instant discount

---

## 👨‍💻 Project Information
- **Course:** Final-Year External Lab Project (UI Engineering / Mobile & Web Computing)
- **Team:** Individual / Dual-developer submission
- **Framework:** Flutter Web (Material 3)
