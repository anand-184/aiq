import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final skillController = TextEditingController();
  late String role;

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _nameController.text);
      await prefs.setString('email', _emailController.text);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ClipPath(
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
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
                      TextFormField(
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
                      const SizedBox(height: 30),
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
                          border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(10),
                          color: colorScheme.onSurface.withOpacity(0.1),
                        ),
                        child: Column(
                          children: [
                            Text("Select Role", style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                                    elevation: 0,
                                    foregroundColor: colorScheme.onSurface,
                                  ),
                                  child: const Text("Employee"),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                                    elevation: 0,
                                    foregroundColor: colorScheme.onSurface,
                                  ),
                                  child: const Text("Manager"),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                                    elevation: 0,
                                    foregroundColor: colorScheme.onSurface,
                                  ),
                                  child: const Text("Admin"),
                                ),
                              ],
                            ),
                          ],
                        )
                      ),
                      const SizedBox(height: 30),
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
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleRegister,
                          child: const Text('Sign Up'),
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
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
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
          )
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
