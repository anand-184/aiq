import 'package:aiq/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Adminhomescreen extends StatefulWidget {
  const Adminhomescreen({super.key});
  @override
  State<Adminhomescreen> createState() => _AdminhomescreenState();
}

class _AdminhomescreenState extends State<Adminhomescreen> {
  final firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _branchNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> branches = [];
  String companyName = "Techcadd";

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  void fetchBranches() async {
    try {
      final QuerySnapshot querySnapshot =
          await firestore.collection("branches").get();
      final List<DocumentSnapshot> documents = querySnapshot.docs;
      setState(() {
        branches = documents.map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String).toList();
      });
    } catch (e) {
      debugPrint("Error fetching branches: $e");
    }
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _descriptionController.dispose();
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
                height: 220, width: double.infinity, color: colorScheme.primary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddBranchDialog(context);
        },
        child: const Icon(Icons.add, size: 30),
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primary,
        elevation: 50,
      ),
    );
  }

  void showAddBranchDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _branchNameController,
                        keyboardType: TextInputType.name,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: const InputDecoration(
                            hintText: 'Enter Branch Name',
                            icon: Icon(Icons.business)),
                        validator: (value) {
                          if (value == null || value.isEmpty ) {
                            return 'Please enter branch name';
                          }else if(!branches.contains(value))
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: const InputDecoration(
                            hintText: 'Enter Branch Description',
                            icon: Icon(Icons.description)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (!branches.contains(_branchNameController.text)) {
                              await firestore.collection("branches").add({
                                "branchId": firestore.collection("branches").doc().id,
                                "name": _branchNameController.text,
                                "description": _descriptionController.text,
                                "companyName": companyName,
                              });
                              fetchBranches();
                              if (mounted) Navigator.pop(context);
                              _branchNameController.clear();
                              _descriptionController.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Branch already exists")),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text("Add Branch"),
                      )
                    ],
                  ))),
        );
      },
    );
  }
}

class TopShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width - 280, size.height, size.width / 2 - 30, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2 - 5, size.height - 80, size.width / 2 + 30, size.height - 150);
    path.quadraticBezierTo(size.width / 2 + 55, size.height - 90, size.width + 60, 0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
