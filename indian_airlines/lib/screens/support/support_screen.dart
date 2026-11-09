import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../core/validators.dart';
import '../../data/faq.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// Customer support screen with searchable categorized FAQs, contact form & star rating feedback
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _selectedCategory = 'All';
  String _faqSearchQuery = '';

  // Forms
  final _contactFormKey = GlobalKey<FormState>();
  final _contactName = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactMessage = TextEditingController();

  int _rating = 5;
  final _feedbackText = TextEditingController();

  @override
  void dispose() {
    _contactName.dispose();
    _contactEmail.dispose();
    _contactMessage.dispose();
    _feedbackText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNav(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              color: AppConstants.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              width: double.infinity,
              child: ResponsiveContainer(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Support & Help Center',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Search our knowledge base, submit a ticket, or provide feedback on your travel experience',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. FAQ Search & Categories
                  _buildFaqSection(context),

                  const SizedBox(height: 40),

                  // 2. Contact Us Form & Direct Channels
                  _buildContactSection(context),

                  const SizedBox(height: 40),

                  // 3. Passenger Experience Feedback (Star Rating)
                  _buildFeedbackSection(context),
                ],
              ),
            ),

            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    var items = FaqData.items;
    if (_selectedCategory != 'All') {
      items = items.where((f) => f.category == _selectedCategory).toList();
    }
    if (_faqSearchQuery.isNotEmpty) {
      items = items
          .where((f) =>
              f.question.toLowerCase().contains(_faqSearchQuery.toLowerCase()) ||
              f.answer.toLowerCase().contains(_faqSearchQuery.toLowerCase()))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Search Input
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Search FAQ by keyword (e.g. baggage, refund, check-in, pet)',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (val) => setState(() => _faqSearchQuery = val.trim()),
        ),
        const SizedBox(height: 12),
        // Category Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: FaqData.categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppConstants.saffron.withValues(alpha: 0.25),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // FAQ Expansion Tiles
        ...items.map(
          (faq) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ExpansionTile(
              title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(faq.answer, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _contactFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send Us a Message / Raise a Concern', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Our demo support team will review your message.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contactName,
                      decoration: const InputDecoration(labelText: 'Your Name *'),
                      validator: AppValidators.validateName,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _contactEmail,
                      decoration: const InputDecoration(labelText: 'Email Address *'),
                      validator: AppValidators.validateEmail,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactMessage,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Message / Grievance Details *'),
                validator: (val) => AppValidators.requiredField(val, 'Please write your message'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_contactFormKey.currentState?.validate() ?? false) {
                    _contactName.clear();
                    _contactEmail.clear();
                    _contactMessage.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Support ticket created. Reference #IA-TKT-9912'),
                        backgroundColor: AppConstants.accentGreen,
                      ),
                    );
                  }
                },
                child: const Text('Submit Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Passenger Experience Star Rating', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('How would you rate your booking and flying experience with Indian Airlines?'),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                final starNum = index + 1;
                return IconButton(
                  icon: Icon(
                    starNum <= _rating ? Icons.star : Icons.star_border,
                    color: AppConstants.saffron,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = starNum),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _feedbackText,
              decoration: const InputDecoration(hintText: 'Share comments about our web app experience (optional)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _feedbackText.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for rating Indian Airlines! Your feedback has been noted.'),
                    backgroundColor: AppConstants.accentGreen,
                  ),
                );
              },
              child: const Text('Submit Star Rating'),
            ),
          ],
        ),
      ),
    );
  }
}

