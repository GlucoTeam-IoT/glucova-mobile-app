import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/glucova_logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 20),
                  
                  // Create account text
                  const Text(
                    'Create Your GlucoVa Account',
                    style: AppStyles.titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  // First Name and Last Name row
                  Row(
                    children: [
                      // First Name Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('First Name', style: AppStyles.subtitleStyle),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _firstNameController,
                              decoration: AppStyles.inputDecoration(
                                hintText: 'First Name',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Last Name Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Last Name', style: AppStyles.subtitleStyle),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _lastNameController,
                              decoration: AppStyles.inputDecoration(
                                hintText: 'Last Name',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Email Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email Address', style: AppStyles.subtitleStyle),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: AppStyles.inputDecoration(
                          hintText: 'Enter your email',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Password', style: AppStyles.subtitleStyle),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: AppStyles.inputDecoration(
                          hintText: 'Enter your password',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Confirm Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Confirm Password', style: AppStyles.subtitleStyle),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: AppStyles.inputDecoration(
                          hintText: 'Confirm your password',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Terms of Service Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value!;
                          });
                        },
                        activeColor: AppColors.primaryRed,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: const TextStyle(color: AppColors.textDark),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: AppStyles.linkStyle,
                              ),
                              const TextSpan(
                                text: ' and ',
                                style: TextStyle(color: AppColors.textDark),
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppStyles.linkStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreeToTerms
                          ? () {
                              // Handle create account
                            }
                          : null,
                      style: AppStyles.primaryButtonStyle,
                      child: const Text(
                        'Create Account',
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate back to login screen
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: AppStyles.linkStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
