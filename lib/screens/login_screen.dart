import 'package:aiq/screens/adminScreens/admin_dashboard.dart';
import 'package:aiq/screens/empScreens/emp_homescreen.dart';
import 'package:aiq/screens/super_admin_screens/super_admin_dashboard.dart';
import 'package:aiq/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            String result = await authService.loginUser(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            if (result == "success") {
                              final User? user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Authentication failed: User is null")),
                                  );
                                }
                                return;
                              }

                              // 1. Super Admin Check (Direct Bypass)
                              final normalizedEmail = user.email?.toLowerCase() ?? "";
                              if (normalizedEmail == "anandita.9464@gmail.com" || 
                                  normalizedEmail == "anandita9464@gmail.com") {
                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SuperAdminDashboard()),
                                  );
                                }
                                return;
                              }

                              // 2. Fetch User Role from Firestore
                              try {
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();

                                if (!mounted) return;

                                if (userDoc.exists) {
                                  final data = userDoc.data();
                                  final String role =
                                      (data?['role'] as String? ?? "").trim();

                                  if (role == "SuperAdmin") {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SuperAdminDashboard()));
                                  } else if (role == "Manager" || role == "Admin") {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CompanyAdminDashboard()));
                                  } else if (role == "Employee") {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const EmpHomescreen()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Account role is missing. Please ask your admin to recreate or update this team member.",
                                        ),
                                      ),
                                    );
                                    setState(() => _isLoading = false);
                                  }
                                } else {
                                  // NEW: Fallback for Company Admins whose user profile might be missing
                                  final companyQuery = await FirebaseFirestore.instance
                                      .collection('companies')
                                      .where('ownerEmail', isEqualTo: user.email)
                                      .limit(1)
                                      .get();

                                  if (companyQuery.docs.isNotEmpty) {
                                    // It's a company admin, but profile is missing. 
                                    // Let's create the missing profile now.
                                    final companyData = companyQuery.docs.first.data();
                                    final companyId = companyData['companyId'];
                                    final companyName = companyData['name'];
                                    final ownerName = companyData['ownerName'];

                                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                                      'userId': user.uid,
                                      'companyId': companyId,
                                      'companyName': companyName,
                                      'name': ownerName,
                                      'email': user.email,
                                      'role': 'Manager',
                                      'branchId': 'Main',
                                      'empId': 'ADMIN-$companyId',
                                      'maxCapacityHoursPerWeek': 40.0,
                                      'currentWorkloadPercentage': 0.0,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                    if (mounted) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const CompanyAdminDashboard()));
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Account profile not found. Please register again.")),
                                    );
                                    setState(() => _isLoading = false);
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error fetching profile: $e")),
                                  );
                                  setState(() => _isLoading = false);
                                }
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result)),
                                );
                                setState(() => _isLoading = false);
                              }
                            }

                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
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
                            style: GoogleFonts.montserrat(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: GoogleFonts.montserrat(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold),
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
