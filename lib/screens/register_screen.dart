import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../services/auth_service.dart';

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
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  String _errorMessage = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Método para manejar el registro de usuarios
  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Validaciones básicas
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete los campos requeridos';
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
        _isLoading = false;
      });
      return;
    }

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Debe aceptar los términos y condiciones';
        _isLoading = false;
      });
      return;
    }

    try {
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Navegar a la pantalla principal después de un registro exitoso
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('409')) {
          _errorMessage = 'El correo electrónico ya está registrado. Por favor, usa otro email o inicia sesión.';
        } else if (e.toString().contains('Tiempo de espera')) {
          _errorMessage = 'El servidor está tardando en responder. Por favor, inténtalo más tarde.';
        } else if (e.toString().contains('Exception:')) {
          _errorMessage = e.toString().split('Exception: ')[1];
        } else {
          _errorMessage = 'Error al registrar usuario: ${e.toString()}';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                          text: const TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(color: AppColors.textDark),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: AppStyles.linkStyle,
                              ),
                              TextSpan(
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
                  const SizedBox(height: 24),
                  
                  // Error message if exists
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  
                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_agreeToTerms && !_isLoading)
                          ? _handleRegister
                          : null,
                      style: AppStyles.primaryButtonStyle,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
