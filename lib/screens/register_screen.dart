import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  String role = "Employee";
  String? branchId;
  bool _isOtpVisible = false;

  @override
  void initState(){
    super.initState();
    getBranches();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _nameController.text);
      await prefs.setString('email', _emailController.text);
      try{
        await AuthService().registerUser(
          email: _emailController.text.trim(),
          password: _otpController.text.trim(),
          companyName: "AIQ",
          branchId: branchId.toString(),
          empId: firestore.collection("users").doc().id,
          name: _nameController.text.trim(),
          phone: _phoneController.text,
          role: role,
          skills: skillController.text.split(","),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration Successful"),
            duration: Duration(seconds: 3),
          ),
        );
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: Duration(seconds: 3),
          ),
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
      }catch(e){
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
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          // 1. FIXED HEADER
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
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Sign Up ",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // 2. SCROLLABLE FORM SECTION
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: const InputDecoration(
                          hintText: 'Enter Your Name',
                          icon: Icon(Icons.person)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: colorScheme.onSurface),
                            decoration: const InputDecoration(
                                hintText: 'Enter Email Address',
                                icon: Icon(Icons.email)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isOtpVisible = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text("Verify"),
                        ),
                      ],
                    ),
                    if (_isOtpVisible) ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: const InputDecoration(
                            hintText: 'Enter OTP Code',
                            icon: Icon(Icons.security)),
                        validator: (value) {
                          if (_isOtpVisible && (value == null || value.isEmpty)) {
                            return 'Please enter OTP';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: const InputDecoration(
                          hintText: 'Enter Phone Number',
                          icon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 30),
                    Container(
                        padding: const EdgeInsets.all(12),
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
                            Wrap(
                              alignment: WrapAlignment.spaceEvenly,
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
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
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      role = "Admin";
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: role == "Admin"
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withValues(alpha: 0.1),
                                    elevation: 0,
                                    foregroundColor: role == "Admin"
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                  child: const Text("Admin"),
                                ),
                              ],
                            ),
                          ],
                        )),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      value:branchId,
                      decoration: const InputDecoration(
                        labelText: 'Select Branch',
                        icon: Icon(Icons.location_on),
                      ),
                      items: branches.map((branch) {
                        return DropdownMenuItem<String>(
                    value: branch['branchId'],
                    child: Text(branch['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          branchId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a branch';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),
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
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // 3. FIXED FOOTER (Button and Sign In link)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already Have An Account? ",
                            style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
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

    path.quadraticBezierTo(size.width / 2 + 170, size.height, size.width + 150,
        size.height - 550);

    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
