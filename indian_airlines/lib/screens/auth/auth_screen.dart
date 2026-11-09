import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/footer.dart';
import '../../widgets/top_nav.dart';

/// Authentication screen with Sign In, Sign Up, password visibility toggle and form validation
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Sign In inputs
  final _signInEmailController = TextEditingController(text: 'rahul.sharma@example.com');
  final _signInPasswordController = TextEditingController(text: 'Password123');
  bool _obscureSignInPassword = true;

  // Sign Up inputs
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  bool _obscureSignUpPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPhoneController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const TopNav(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 36),
            ResponsiveContainer(
              maxWidth: 480,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    children: [
                      const AppLogo(size: 42),
                      const SizedBox(height: 16),
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AppConstants.saffron,
                        labelColor: AppConstants.primaryNavy,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Sign In'),
                          Tab(text: 'Create Account'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 380,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSignInForm(context, auth),
                            _buildSignUpForm(context, auth),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context, AuthProvider auth) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signInEmailController,
            decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
            validator: AppValidators.validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signInPasswordController,
            obscureText: _obscureSignInPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureSignInPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureSignInPassword = !_obscureSignInPassword),
              ),
            ),
            validator: AppValidators.validatePassword,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Password Reset'),
                    content: const Text('In this educational demo, password resets are simulated. You can log in with any sample email & password.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                    ],
                  ),
                );
              },
              child: const Text('Forgot Password?', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: auth.isLoading
                ? null
                : () async {
                    if (_signInFormKey.currentState?.validate() ?? false) {
                      await auth.login(
                        _signInEmailController.text.trim(),
                        _signInPasswordController.text,
                      );
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/profile');
                      }
                    }
                  },
            child: auth.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Sign In to Account'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Demo Hint: Sign in with the pre-filled account or create a new profile.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context, AuthProvider auth) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signUpNameController,
            decoration: const InputDecoration(labelText: 'Full Name as on Photo ID', prefixIcon: Icon(Icons.person_outline)),
            validator: AppValidators.validateName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signUpEmailController,
            decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
            validator: AppValidators.validateEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signUpPhoneController,
            decoration: const InputDecoration(labelText: '10-digit Mobile', prefixIcon: Icon(Icons.phone_outlined)),
            validator: AppValidators.validatePhone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signUpPasswordController,
            obscureText: _obscureSignUpPassword,
            decoration: InputDecoration(
              labelText: 'Create Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureSignUpPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureSignUpPassword = !_obscureSignUpPassword),
              ),
            ),
            validator: AppValidators.validatePassword,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: auth.isLoading
                ? null
                : () async {
                    if (_signUpFormKey.currentState?.validate() ?? false) {
                      await auth.register(
                        name: _signUpNameController.text.trim(),
                        email: _signUpEmailController.text.trim(),
                        phone: _signUpPhoneController.text.trim(),
                        password: _signUpPasswordController.text,
                      );
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/profile');
                      }
                    }
                  },
            child: const Text('Create Account (+500 Welcome Pts)'),
          ),
        ],
      ),
    );
  }
}

