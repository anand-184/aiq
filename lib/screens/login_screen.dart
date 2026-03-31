import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Re-using the pristine Theme palette
  static const midnightBlue = Color(0xFF081F5C);
  static const jicamaWhite = Color(0xFFFFF9F0);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // TODO: Firebase Integration (Skipped for now per requirement)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          // Navigate to Dashboard when implemented
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: midnightBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header ---
                  const Icon(Icons.auto_awesome, color: jicamaWhite, size: 32),
                  const SizedBox(height: 16),
                  Text(
                    'AIQ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: jicamaWhite,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AUTHENTICATION REQUIRED',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: jicamaWhite.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 6.0,
                    ),
                  ),
                  const SizedBox(height: 64),

                  // --- Email Field ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: jicamaWhite),
                    decoration: _buildInputDecoration('Corporate Email', Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- Password Field ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: jicamaWhite),
                    decoration: _buildInputDecoration('Password', Icons.lock_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  // Forgot Password text
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: jicamaWhite.withOpacity(0.6),
                        textStyle: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                      ),
                      child: const Text('FORGOT PASSWORD?'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- Login Button ---
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jicamaWhite,
                        foregroundColor: midnightBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(midnightBlue),
                              ),
                            )
                          : Text(
                              'SIGN IN',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.0,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom transparent/minimalist input border configuration
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: jicamaWhite.withOpacity(0.2)),
    );
    
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(
        color: jicamaWhite.withOpacity(0.5),
        fontSize: 12,
        letterSpacing: 1.0,
      ),
      prefixIcon: Icon(icon, color: jicamaWhite.withOpacity(0.5), size: 18),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: jicamaWhite),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
    );
  }
}
