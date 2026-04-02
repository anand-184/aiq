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
  late String role ;

  static const darkBlue = Color(0xFF002140);

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Correct implementation of SharedPreferences
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            ClipPath(
              clipper: TopShapeClipper(),
              child: Container(
                height: 250,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Sign Up ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(child :Form(key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // name
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(color: darkBlue),
                      decoration: _buildInputDecoration('Enter Your Name', Colors.white,
                          const Icon(Icons.person, color: darkBlue)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    //email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: darkBlue),
                      decoration: _buildInputDecoration('Enter Email Address',
                          Colors.white,const Icon(Icons.email, color: darkBlue)),
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
                      style: const TextStyle(color: darkBlue),
                      decoration: _buildInputDecoration('Enter Phone Number',
                          Colors.white,const Icon(Icons.phone, color: darkBlue)),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(onPressed: (){}, child: Text("Employee"),style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            elevation: 5,
                            foregroundColor: Colors.white,
                          )),
                          SizedBox(width: 10,),
                          ElevatedButton(onPressed: (){}, child: Text("Manager"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                elevation: 5,
                                foregroundColor: Colors.white,
                              )),
                          SizedBox(width: 10,),
                          ElevatedButton(onPressed: (){}, child: Text("Admin"),style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            elevation: 5,
                            foregroundColor: Colors.white,
                          ),),
                        ],
                      ),

                    )
                    ,
                    SizedBox(height: 30,),
                    TextFormField(
                      controller: skillController ,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(color: darkBlue),
                      decoration: _buildInputDecoration('Enter Skills (*Separated by Commas)',
                          Colors.white,const Icon(Icons.person, color: darkBlue)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your skills';
                        }
                        return null;
                      },
                    ),

                    //password
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ),
                  ],
                ),
              ),
    )

            )
          ],
        ),
      );
  }
}
InputDecoration _buildInputDecoration(String hint, Color fillColor, Icon icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
    filled: true,
    icon: icon,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
  );
}
class TopShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0,size.height);
    path.lineTo((size.width/2)+40, size.height);

    path.quadraticBezierTo(
        size.width/2+170, size.height,
        size.width+150, size.height-550);

    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
