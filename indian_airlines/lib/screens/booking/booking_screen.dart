import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/responsive.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/eticket_view.dart';
import '../../widgets/footer.dart';
import '../../widgets/seat_map.dart';
import '../../widgets/top_nav.dart';

/// 5-step booking flow: Review -> Passenger Details -> Add-ons & Seats -> Payment -> Confirmation
class BookingScreen extends StatefulWidget {
  final String? initialStep;
  const BookingScreen({super.key, this.initialStep});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final _passengerFormKey = GlobalKey<FormState>();
  final _paymentFormKey = GlobalKey<FormState>();

  // Payment inputs
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Contact inputs
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstController = TextEditingController();
  final _companyController = TextEditingController();

  late AnimationController _checkmarkController;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final booking = context.read<BookingProvider>();
    _emailController.text = booking.contactEmail;
    _phoneController.text = booking.contactPhone;
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gstController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();

    // If no flight selected in state, redirect back to home
    if (booking.flight == null) {
      return Scaffold(
        appBar: const TopNav(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flight_takeoff, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No active booking in progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                child: const Text('Search Flights'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const TopNav(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Stepper Navigation Header
            _buildStepperHeader(context, booking),

            const SizedBox(height: 20),

            // Step Content
            ResponsiveContainer(
              child: [
                _buildStep0Review(context, booking),
                _buildStep1Passengers(context, booking),
                _buildStep2Addons(context, booking),
                _buildStep3Payment(context, booking),
                _buildStep4Confirmation(context, booking),
              ][booking.currentStep],
            ),

            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  // --- Top Progress Stepper ---
  Widget _buildStepperHeader(BuildContext context, BookingProvider booking) {
    const steps = [
      '1. Review',
      '2. Passengers',
      '3. Add-ons & Seats',
      '4. Payment',
      '5. Confirmation',
    ];

    return Container(
      color: AppConstants.primaryNavy,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(steps.length, (index) {
                      final isActive = index == booking.currentStep;
                      final isPassed = index < booking.currentStep;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: isPassed
                                ? AppConstants.accentGreen
                                : (isActive ? AppConstants.saffron : Colors.white24),
                            child: isPassed
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? AppConstants.primaryNavy : Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            steps[index],
                            style: TextStyle(
                              color: isActive ? AppConstants.saffron : (isPassed ? Colors.white : Colors.white54),
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          if (index < steps.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.chevron_right, size: 16, color: Colors.white30),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              // 10-Minute Countdown Session Timer
              if (booking.currentStep < 4)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppConstants.saffron),
                      const SizedBox(width: 4),
                      Text(
                        booking.formattedTimer,
                        style: const TextStyle(
                          color: AppConstants.saffron,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Step 0: Review Itinerary & Fare Breakdown ---
  Widget _buildStep0Review(BuildContext context, BookingProvider booking) {
    final flight = booking.flight!;
    final pricing = booking.currentPricing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Review Itinerary & Fare Breakdown',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppConstants.primaryNavy),
        ),
        const SizedBox(height: 16),

        // Itinerary Summary Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outbound Flight: ${flight.origin.city} (${flight.origin.code}) → ${flight.destination.city} (${flight.destination.code})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        flight.flightNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryNavy),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppFormatters.formatDate(flight.departureTime)} • Departure ${AppFormatters.formatTime(flight.departureTime)} • Arrival ${AppFormatters.formatTime(flight.arrivalTime)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  'Aircraft: ${flight.aircraft} • Cabin: ${booking.fareOption?.name ?? 'Economy'}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Pricing Breakdown Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fare Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                _buildPriceRow('Base Fare (${booking.passengers.length} passenger/s)', pricing.baseFare),
                _buildPriceRow('Taxes & Airport Development Fees', pricing.taxesAndFees),
                _buildPriceRow('Fuel Surcharge (YQ)', pricing.fuelSurcharge),
                _buildPriceRow('Convenience Fee', pricing.convenienceFee),
                if (pricing.promoDiscount > 0)
                  _buildPriceRow('Promo Code Discount', -pricing.promoDiscount, isDiscount: true),
                const Divider(),
                _buildPriceRow('Grand Total', pricing.grandTotal, isTotal: true),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () => booking.setStep(1),
              child: const Text('Proceed to Passenger Details'),
            ),
          ],
        ),
      ],
    );
  }

  // --- Step 1: Passenger Details Form ---
  Widget _buildStep1Passengers(BuildContext context, BookingProvider booking) {
    final isIntl = !booking.flight!.origin.isDomestic || !booking.flight!.destination.isDomestic;

    return Form(
      key: _passengerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 2: Passenger & Contact Information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppConstants.primaryNavy),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please ensure passenger names exactly match government-issued photo ID.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Dynamic Passenger Forms
          ...List.generate(booking.passengers.length, (index) {
            final p = booking.passengers[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passenger ${index + 1} (${p.type})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField<String>(
                            initialValue: p.title,
                            decoration: const InputDecoration(labelText: 'Title'),
                            items: const [
                              DropdownMenuItem(value: 'Mr', child: Text('Mr')),
                              DropdownMenuItem(value: 'Ms', child: Text('Ms')),
                              DropdownMenuItem(value: 'Mrs', child: Text('Mrs')),
                              DropdownMenuItem(value: 'Dr', child: Text('Dr')),
                              DropdownMenuItem(value: 'Master', child: Text('Master')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                booking.updatePassenger(index, p.copyWith(title: val));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: p.firstName,
                            decoration: const InputDecoration(labelText: 'First & Middle Name'),
                            validator: AppValidators.validateName,
                            onChanged: (val) {
                              booking.updatePassenger(index, p.copyWith(firstName: val.trim()));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: p.lastName,
                            decoration: const InputDecoration(labelText: 'Last Name'),
                            validator: AppValidators.validateName,
                            onChanged: (val) {
                              booking.updatePassenger(index, p.copyWith(lastName: val.trim()));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: DropdownButtonFormField<String>(
                            initialValue: p.gender,
                            decoration: const InputDecoration(labelText: 'Gender'),
                            items: const [
                              DropdownMenuItem(value: 'Male', child: Text('Male')),
                              DropdownMenuItem(value: 'Female', child: Text('Female')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                booking.updatePassenger(index, p.copyWith(gender: val));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: p.nationality,
                            decoration: const InputDecoration(labelText: 'Nationality'),
                            onChanged: (val) {
                              booking.updatePassenger(index, p.copyWith(nationality: val.trim()));
                            },
                          ),
                        ),
                        if (isIntl) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: p.passportNumber,
                              decoration: const InputDecoration(labelText: 'Passport Number *'),
                              validator: (val) => AppValidators.validatePassport(val, required: true),
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (val) {
                                booking.updatePassenger(index, p.copyWith(passportNumber: val.trim().toUpperCase()));
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          // Contact Details Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Booking Contact Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email_outlined)),
                          validator: AppValidators.validateEmail,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: '10-digit Mobile Number *', prefixIcon: Icon(Icons.phone_outlined)),
                          validator: AppValidators.validatePhone,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => booking.setStep(0),
                child: const Text('Back to Review'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_passengerFormKey.currentState?.validate() ?? false) {
                    booking.setContactDetails(
                      email: _emailController.text.trim(),
                      phone: _phoneController.text.trim(),
                    );
                    booking.setStep(2);
                  }
                },
                child: const Text('Proceed to Add-ons & Seats'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Step 2: Add-ons & Interactive Seat Map ---
  Widget _buildStep2Addons(BuildContext context, BookingProvider booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3: Customise Your Journey with Add-ons',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppConstants.primaryNavy),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select your preferred seats, gourmet meals, excess baggage and priority boarding.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Interactive Seat Map Widget
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text('Interactive Seat Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                SeatMapWidget(
                  flightNumber: booking.flight!.flightNumber,
                  flightDate: booking.flight!.departureTime,
                  passengers: booking.passengers,
                  onSeatSelected: (paxId, seatCode) {
                    booking.selectSeat(paxId, seatCode);
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Ancillary Add-ons (Meals, Baggage, Insurance)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('In-Flight Meals & Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...List.generate(booking.passengers.length, (idx) {
                  final p = booking.passengers[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${p.fullName.isNotEmpty ? p.fullName : 'Passenger ${idx + 1}'}:', style: const TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<String>(
                          value: p.mealPreference ?? 'Standard Vegetarian',
                          items: const [
                            DropdownMenuItem(value: 'Standard Vegetarian', child: Text('Vegetarian Hindu Meal (AVML)')),
                            DropdownMenuItem(value: 'Non-Vegetarian', child: Text('Non-Vegetarian Meal (NVML)')),
                            DropdownMenuItem(value: 'Jain Meal', child: Text('Jain Meal (VJML)')),
                            DropdownMenuItem(value: 'Diabetic Meal', child: Text('Diabetic Meal (DBML)')),
                          ],
                          onChanged: (val) {
                            if (val != null) booking.selectMeal(p.id, val);
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                SwitchListTile(
                  title: const Text('Comprehensive Travel Insurance (₹299/pax)'),
                  subtitle: const Text('Covers baggage loss, medical emergencies and trip cancellations'),
                  value: booking.hasInsurance,
                  onChanged: (val) => booking.toggleInsurance(val),
                ),
                SwitchListTile(
                  title: const Text('Priority Check-in & Boarding (₹399/pax)'),
                  subtitle: const Text('Dedicated check-in desk and priority baggage tag'),
                  value: booking.hasPriorityBoarding,
                  onChanged: (val) => booking.togglePriorityBoarding(val),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => booking.setStep(1),
              child: const Text('Back to Passengers'),
            ),
            ElevatedButton(
              onPressed: () => booking.setStep(3),
              child: Text('Proceed to Payment (${AppFormatters.formatCurrency(booking.currentPricing.grandTotal)})'),
            ),
          ],
        ),
      ],
    );
  }

  // --- Step 3: Payment Form with Luhn Validation & 10-Min Timer ---
  Widget _buildStep3Payment(BuildContext context, BookingProvider booking) {
    final auth = context.watch<AuthProvider>();
    final pricing = booking.currentPricing;

    return Form(
      key: _paymentFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 4: Secure Mock Payment Gateway',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppConstants.primaryNavy),
          ),
          const SizedBox(height: 4),

          // Mandatory College Project Disclaimer Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade400),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.amber.shade800, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'NOTE: ${AppConstants.demoDisclaimer}. Do not enter real credit card PINs or passwords.',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Skyward Club Points Redemption Toggle
          if (auth.currentUser != null && auth.currentUser!.skywardPoints > 0)
            Card(
              elevation: 1,
              child: SwitchListTile(
                title: Text('Redeem Skyward Club Points (${auth.currentUser!.skywardPoints} available)'),
                subtitle: const Text('1 point = ₹0.50 discount on your base fare'),
                value: booking.redeemPoints,
                onChanged: (val) => booking.toggleRedeemPoints(val, auth.currentUser!.skywardPoints),
              ),
            ),

          const SizedBox(height: 16),

          // Payment Methods Tabs
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'UPI', label: Text('UPI / QR')),
                      ButtonSegment(value: 'Card', label: Text('Credit/Debit Card')),
                      ButtonSegment(value: 'Net Banking', label: Text('Net Banking')),
                      ButtonSegment(value: 'Wallet', label: Text('Wallet')),
                    ],
                    selected: {booking.paymentMethod},
                    onSelectionChanged: (set) => booking.setPaymentMethod(set.first),
                  ),
                  const SizedBox(height: 20),

                  // UPI Tab Form
                  if (booking.paymentMethod == 'UPI') ...[
                    TextFormField(
                      controller: _upiController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Virtual Payment Address (VPA) / UPI ID',
                        hintText: 'username@okaxis, user@okhdfcbank, mobile@paytm',
                        prefixIcon: Icon(Icons.qr_code_2),
                      ),
                      validator: (val) => val == null || !val.contains('@') ? 'Enter valid UPI ID (e.g. user@okhdfcbank)' : null,
                    ),
                    const SizedBox(height: 12),
                    const Text('Supported apps: Google Pay, PhonePe, Paytm, BHIM UPI', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],

                  // Card Tab Form with Luhn Validation & Formatters
                  if (booking.paymentMethod == 'Card') ...[
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CardNumberInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        hintText: '4532 0156 8921 4452',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      validator: AppValidators.validateCardNumber,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cardExpiryController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CardExpiryInputFormatter()],
                            decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                            validator: AppValidators.validateExpiryDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cardCvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 4,
                            decoration: const InputDecoration(labelText: 'CVV', counterText: ''),
                            validator: AppValidators.validateCvv,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cardHolderController,
                      decoration: const InputDecoration(labelText: 'Cardholder Name as on Card'),
                      validator: AppValidators.validateName,
                    ),
                  ],

                  // Net Banking Tab Form
                  if (booking.paymentMethod == 'Net Banking') ...[
                    DropdownButtonFormField<String>(
                      initialValue: booking.selectedBank,
                      decoration: const InputDecoration(labelText: 'Select Bank'),
                      items: const [
                        DropdownMenuItem(value: 'State Bank of India', child: Text('State Bank of India')),
                        DropdownMenuItem(value: 'HDFC Bank', child: Text('HDFC Bank')),
                        DropdownMenuItem(value: 'ICICI Bank', child: Text('ICICI Bank')),
                        DropdownMenuItem(value: 'Axis Bank', child: Text('Axis Bank')),
                        DropdownMenuItem(value: 'Punjab National Bank', child: Text('Punjab National Bank')),
                      ],
                      onChanged: (val) {
                        if (val != null) booking.setBank(val);
                      },
                    ),
                  ],

                  // Wallet Tab Form
                  if (booking.paymentMethod == 'Wallet') ...[
                    DropdownButtonFormField<String>(
                      initialValue: booking.selectedWallet,
                      decoration: const InputDecoration(labelText: 'Select Wallet'),
                      items: const [
                        DropdownMenuItem(value: 'Paytm Wallet', child: Text('Paytm Wallet')),
                        DropdownMenuItem(value: 'Amazon Pay', child: Text('Amazon Pay')),
                        DropdownMenuItem(value: 'PhonePe Wallet', child: Text('PhonePe Wallet')),
                        DropdownMenuItem(value: 'Mobikwik', child: Text('Mobikwik')),
                      ],
                      onChanged: (val) {
                        if (val != null) booking.setWallet(val);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => booking.setStep(2),
                child: const Text('Back to Add-ons'),
              ),
              ElevatedButton(
                onPressed: booking.isPaymentProcessing
                    ? null
                    : () async {
                        if (booking.paymentMethod == 'Card') {
                          if (!(_paymentFormKey.currentState?.validate() ?? false)) return;
                        }
                        // Trigger processing dialog and completion
                        final success = await booking.processPayment();
                        if (success) {
                          _checkmarkController.forward();
                        }
                      },
                child: booking.isPaymentProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Pay ${AppFormatters.formatCurrency(pricing.grandTotal)}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Step 4: Confirmation & E-Ticket ---
  Widget _buildStep4Confirmation(BuildContext context, BookingProvider booking) {
    final confirmed = booking.confirmedBooking;
    if (confirmed == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Animated Checkmark Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppConstants.accentGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppConstants.accentGreen),
          ),
          child: Column(
            children: [
              ScaleTransition(
                scale: CurvedAnimation(parent: _checkmarkController, curve: Curves.elasticOut),
                child: const CircleAvatar(
                  radius: 36,
                  backgroundColor: AppConstants.accentGreen,
                  child: Icon(Icons.check, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Booking Confirmed Successfully!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppConstants.accentGreen),
              ),
              const SizedBox(height: 4),
              Text(
                'Your e-ticket has been issued. PNR Reference: ${confirmed.pnr}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // E-Ticket View
        ETicketView(booking: confirmed),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/manage'),
              icon: const Icon(Icons.airplane_ticket),
              label: const Text('View in My Trips'),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              icon: const Icon(Icons.home),
              label: const Text('Book Another Flight'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? AppConstants.accentGreen : null,
            ),
          ),
          Text(
            '${isDiscount ? '- ' : ''}${AppFormatters.formatCurrency(amount)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? AppConstants.primaryNavy
                  : (isDiscount ? AppConstants.accentGreen : null),
            ),
          ),
        ],
      ),
    );
  }
}
