import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
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
    // Dynamic Theme extraction locks UI instantly to main.dart's active mode
    final colorScheme = Theme.of(context).colorScheme;
    
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = colorScheme.onSurface;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
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
                  Icon(Icons.auto_awesome, color: primaryColor, size: 36),
                  const SizedBox(height: 16),
                  Text(
                    'AIQ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: textColor,
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
                      color: textColor.withOpacity(0.6),
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
                    style: TextStyle(color: textColor),
                    decoration: _buildInputDecoration('Corporate Email',
                        Icons.email_outlined, textColor, primaryColor),
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
                    style: TextStyle(color: textColor),
                    decoration: _buildInputDecoration('Password', Icons.lock_outline, textColor, primaryColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  // Forgot Password?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        textStyle: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      child: const Text('FORGOT PASSWORD?'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
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

  // Refactored helper specifically consuming dynamically themed colors
  InputDecoration _buildInputDecoration(String label, IconData icon, Color textColor, Color primaryColor) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: textColor.withOpacity(0.2)),
    );
    
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(
        color: textColor.withOpacity(0.5),
        fontSize: 12,
        letterSpacing: 1.0,
      ),
      prefixIcon: Icon(icon, color: textColor.withOpacity(0.5), size: 18),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: Colors.red.shade300, width: 2),
      ),
      filled: true,
      fillColor: textColor.withOpacity(0.04), // Just enough contrast
    );
  }
}
