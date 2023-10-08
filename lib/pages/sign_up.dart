import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/customer_model.dart';
import '../models/owners_model.dart';
import 'sing_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isButtonEnabled = false;
  File? _pickedImage;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  void _checkButtonStatus() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _phoneNumberController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _createAccount(String userType) async {
    // Ensure the function is being called
    print('Create Account button clicked with userType: $userType');

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user != null) {
        final userUid = user.uid;

        final imageURL = await _uploadImageToStorage(userUid);

        if (userType == 'customer') {
          final customer = CustomersModel(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneNumberController.text,
            imageURL: imageURL,
            customerID: userUid,
            type: 'customer',
          );

          await firestore.collection('customers').doc(userUid).set(customer.toMap());
        } else if (userType == 'owner') {
          final owner = OwnersModel(
            shopName: _nameController.text,
            email: _emailController.text,
            phone: _phoneNumberController.text,
            imageURL: imageURL,
            ownerId: userUid,
            type: 'owners',
          );

          await firestore.collection('owners').doc(userUid).set(owner.toMap());
        }

        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _phoneNumberController.clear();
        _pickedImage = null;

        // Reset button status
        _isButtonEnabled = false;

        Get.to((const SignIn()));
        EasyLoading.showToast('Account Created Successfully');
        print('User created successfully as $userType');
      }
    } catch (e) {
      print('Error creating user: $e');
      EasyLoading.showToast('Error creating user: $e');
    }
  }

  Future<String?> _uploadImageToStorage(String userUid) async {
    if (_pickedImage == null) {
      return null;
    }

    try {
      final storage = FirebaseStorage.instance;
      final imageRef = storage.ref().child('users/$userUid/profile.jpg');

      final uploadTask = imageRef.putFile(_pickedImage!);
      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading image to storage: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkButtonStatus);
    _emailController.addListener(_checkButtonStatus);
    _passwordController.addListener(_checkButtonStatus);
    _confirmPasswordController.addListener(_checkButtonStatus);
    _phoneNumberController.addListener(_checkButtonStatus);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text('Create Account'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Customer'),
              Tab(text: 'Owner'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Customer Tab View
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        onPressed: _toggleConfirmPasswordVisibility,
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _createAccount('customer'), // Pass 'customer' as userType
                    child: const Text('Sign Up as Customer'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                  _pickedImage != null
                      ? Image.file(_pickedImage!)
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            // Owner Tab View
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Shop Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        onPressed: _toggleConfirmPasswordVisibility,
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _createAccount('owner'), // Pass 'owner' as userType
                    child: const Text('Sign Up as Owner'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                  _pickedImage != null
                      ? Image.file(_pickedImage!)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),



      ),
    );
  }
}
