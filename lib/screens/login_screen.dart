import 'package:aiq/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aiq/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final authService = AuthService();

  bool _isLoading = false;



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: TopShapeClipper(),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: colorScheme.primary,
                    padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: GoogleFonts.montserrat(
                            color: colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign In',
                          style: GoogleFonts.montserrat(
                            color: colorScheme.onPrimary,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Address',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: colorScheme.onSurface),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter Email Address',
                        icon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
    }),
                    const SizedBox(height: 20),
                    Text(
                      'Password',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: colorScheme.onSurface),
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: 'Enter Your Password',
                        icon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          if( _emailController.text != null && _emailController.text.isNotEmpty){
                            try{
                              FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());

                            }on FirebaseAuthException catch(e){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message.toString(),
                                    style: TextStyle(color: colorScheme.onPrimary)),backgroundColor: colorScheme.primary,),
                              );
                            }catch(e){

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString(),
                                    style: TextStyle(color: colorScheme.onPrimary)),backgroundColor: colorScheme.primary,),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.montserrat(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: (){
                          if(_formKey.currentState!.validate()){
                            setState(() {
                              _isLoading = true;
                            });
                            authService.loginUser
                              (email: _emailController.text.trim(),
                                password: _passwordController.text.trim());
                            if(mounted){
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            }

                          }
                        },
                        child: _isLoading
                            ? CircularProgressIndicator(color: colorScheme.onPrimary)
                            : Text(
                                'Sign In',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't Have An Account? ",
                            style: GoogleFonts.montserrat(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: GoogleFonts.montserrat(color: colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo((size.width / 2) + 40, size.height);

    path.quadraticBezierTo(
        size.width / 2 + 170, size.height,
        size.width + 150, size.height - 550);

    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
