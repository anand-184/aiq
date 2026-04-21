import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> branches = [];
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final skillController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool isVerified = false;
  String? generatedOtp;
  String role = "Employee";
  String? branchId;
  bool _isOtpVisible = false;
  bool _isSendingOtp = false;

  @override
  void initState(){
    super.initState();
    getBranches();
  }

  // 1. Generate OTP
  String _generateOTP() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  // 2. Send OTP to email
  Future<void> _sendOtpEmail() async {
    if(_emailController.text.isEmpty || !_emailController.text.contains("@")){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email address")),
      );
      return;
      
    }
    setState(() {
      _isSendingOtp=true;
      generatedOtp = _generateOTP();
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isOtpVisible = true;
      _isSendingOtp=false;
    });
    
    try{
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost'
        },
        body: json.encode({
          'service_id': 'service_d8gp5lc',
            'template_id': 'template_mm3cdhh',
          'user_id': 'I9yXoi7vrHCfpppNq',
          'template_params': {
            'email': _emailController.text,
            'otp': generatedOtp,
          },
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent successfully!")),

      );
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send OTP")),
        );
      }
    }finally{
      setState(() {
        _isSendingOtp=false;
      });
    }
  }

  // Verify OTP locally
  void _verifyOtp() {
    if (_otpController.text == generatedOtp) {
      setState(() {
        isVerified = true;
        _isOtpVisible = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email verified successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP code")),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please verify your email first")),
        );
        return;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _nameController.text);
      await prefs.setString('email', _emailController.text);
      
      try {
        await AuthService().registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          companyName: "AIQ",
          branchId: branchId.toString(),
          empId: firestore.collection("users").doc().id,
          name: _nameController.text.trim(),
          phone: _phoneController.text,
          role: role,
          skills: skillController.text.split(","),
        );
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void getBranches() async {
    try{
      final querySnapshot = await firestore.collection("branches").get();
      setState(() {
        branches= querySnapshot.docs.map((doc){
          final data = doc.data() as Map<String, dynamic>;
          return {
            "name": data["name"],
            "branchId": doc.id,
          };
        }).toList();
      });
    } catch(e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ClipPath(
              clipper: TopShapeClipper(),
              child: Container(
                height: 230,
                width: double.infinity,
                color: colorScheme.primary,
                padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome!', style: TextStyle( fontSize: 16,color:colorScheme.onPrimary, fontWeight: FontWeight.w500)),
                  Text("Sign Up", style: TextStyle( fontSize: 42, fontWeight: FontWeight.bold,color:colorScheme.onPrimary)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Full Name', icon: Icon(Icons.person)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            readOnly: isVerified,
                            decoration: InputDecoration(
                              hintText: 'Email Address', 
                              icon: const Icon(Icons.email),
                              suffixIcon: isVerified ? const Icon(Icons.check_circle, color: Colors.green) : null,
                            ),
                          ),
                        ),
                        if (!isVerified)
                          TextButton(
                            onPressed: _isSendingOtp ? null : _sendOtpEmail,
                            child: _isSendingOtp ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Verify"),
                          ),
                      ],
                    ),
                    if (_isOtpVisible) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: 'Enter 6-digit OTP', icon: Icon(Icons.lock)),
                            ),
                          ),
                          TextButton(onPressed: _verifyOtp, child: const Text("Confirm")),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(hintText: 'Enter Password', icon: Icon(Icons.lock)),
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(hintText: 'Phone Number', icon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: branchId,
                      hint: const Text("Select Branch"),
                      items: branches.map((b) => DropdownMenuItem(value: b['branchId'] as String, child: Text(b['name']))).toList(),
                      onChanged: (v) => setState(() => branchId = v),
                    ),
                    const SizedBox(height: 20),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal:5,vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: colorScheme.onSurface.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(10),
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                        child: Column(
                          children: [
                            Text("Select Role",
                                style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      role = "Employee";
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: role == "Employee"
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withValues(alpha: 0.1),
                                    elevation: 0,
                                    foregroundColor: role == "Employee"
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                  child: const Text("Employee"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      role = "Manager";
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: role == "Manager"
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withValues(alpha: 0.1),
                                    elevation: 0,
                                    foregroundColor: role == "Manager"
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                  child: const Text("Manager"),
                                ),
                              ],
                            ),
                          ],
                        )),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: skillController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: const InputDecoration(
                          hintText: 'Enter Skills (*Separated by Commas)',
                          icon: Icon(Icons.person)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your skills';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20,),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text('Register'),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already Have An Account? ",
                            style: GoogleFonts.montserrat(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: GoogleFonts.montserrat(color: colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30,),

                  ],
                ),
              ),
            ),
          ),
        ],
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
