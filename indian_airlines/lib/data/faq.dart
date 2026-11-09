/// Frequently asked questions categorized for Support & Travel info screens
class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FaqData {
  static const List<FaqItem> items = [
    // Baggage
    FaqItem(
      category: 'Baggage',
      question: 'What is the standard cabin and check-in baggage allowance?',
      answer:
          'For domestic flights, Economy Saver includes 15 kg check-in baggage and 7 kg cabin baggage. Economy Flex includes 25 kg check-in and 7 kg cabin baggage. Business Class includes 35 kg check-in baggage and 10 kg cabin baggage. International allowances vary from 25 kg to 40 kg.',
    ),
    FaqItem(
      category: 'Baggage',
      question: 'How do I purchase prepaid excess baggage?',
      answer:
          'You can add excess baggage during booking on the Add-ons step or through Manage Booking up to 6 hours before departure at discounted rates (₹500 per 5 kg). Airport excess baggage fees are higher.',
    ),
    FaqItem(
      category: 'Baggage',
      question: 'Can I carry power banks and electronic items in check-in baggage?',
      answer:
          'No. In compliance with DGCA safety regulations, power banks, spare lithium batteries, and electronic cigarettes must strictly be carried in cabin baggage only.',
    ),

    // Check-in & Boarding
    FaqItem(
      category: 'Check-in',
      question: 'When does Web Check-in open and close?',
      answer:
          'Web Check-in opens 48 hours prior to scheduled flight departure and closes 2 hours prior to departure for domestic flights (3 hours for international flights).',
    ),
    FaqItem(
      category: 'Check-in',
      question: 'Do I need to carry a printed boarding pass at the airport?',
      answer:
          'A digital boarding pass displayed on your smartphone or saved as a screenshot is accepted at all major Indian airports alongside your valid government photo ID.',
    ),

    // Cancellations & Refunds
    FaqItem(
      category: 'Cancellations',
      question: 'What is the refund amount if I cancel my flight ticket?',
      answer:
          'If cancelled more than 24 hours prior to departure, you receive an 80% refund of base fare plus all statutory taxes and airport fees (minus a cancellation fee of ₹1,500). If cancelled within 24 hours, you receive a 50% refund minus fee. Economy Flex bookings enjoy reduced cancellation charges.',
    ),
    FaqItem(
      category: 'Cancellations',
      question: 'How long does it take for a refund to process?',
      answer:
          'In this demo app, mock refunds are calculated instantly. On commercial systems, refunds typically reflect in the original payment source within 3-5 business days.',
    ),

    // Skyward Club
    FaqItem(
      category: 'Skyward Club',
      question: 'How do I earn and redeem Skyward Club loyalty points?',
      answer:
          'You earn 5 points per ₹100 spent on Economy fares and 10 points per ₹100 on Business Class. Points can be redeemed at checkout on any subsequent booking (1 point = ₹0.50 discount) or used for cabin upgrades.',
    ),
    FaqItem(
      category: 'Skyward Club',
      question: 'What are the membership tiers and criteria?',
      answer:
          'Silver is the entry tier upon joining. Gold tier is attained with 15,000 Tier Points or 20 flight segments per year. Platinum tier requires 35,000 Tier Points or 40 flight segments, unlocking complimentary lounge access and extra 15 kg baggage.',
    ),

    // Special Assistance
    FaqItem(
      category: 'Special Assistance',
      question: 'How can I request wheelchair assistance for senior passengers?',
      answer:
          'Wheelchair assistance can be requested free of charge through the "Prepare to Travel > Special Assistance" form or via Manage Booking up to 24 hours prior to flight departure.',
    ),
  ];

  static List<String> get categories => [
        'All',
        'Baggage',
        'Check-in',
        'Cancellations',
        'Skyward Club',
        'Special Assistance',
      ];
}
