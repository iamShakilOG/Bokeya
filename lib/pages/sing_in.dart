import 'package:dues/pages/owner_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'customer_dashboard.dart';
import 'owner_dashboard.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signInWithEmailAndPassword() async {
    final pre = await SharedPreferences.getInstance();


    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if the sign-in was successful
      if (userCredential.user != null) {
        final String userType = await _getUserType(userCredential.user!.uid);
        pre.setString('user_id', userCredential.user!.uid);
        pre.setString('customer', userType);
        var userID = pre.getString("user_id");
        print("userID value: $userID");

        if (userType == 'customer') {
          Get.to(() => CustomerDashboard());
          // User is a customer
          // Handle customer login here if needed
        } else if (userType == 'owner') {
          // User is an owner
          pre.setString('owner_id', userCredential.user!.uid);
          pre.setString('owners', userType);

          var ownerId = pre.getString("owner_id");


          Get.to(() => OwnerProfile());
        } else {
          // Handle other user types or show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid User Type'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print("Error signing in: $e");
      // Handle sign-in errors here, e.g., show an error dialog
    }
  }


  Future<String> _getUserType(String userId) async {
    try {
      final DocumentSnapshot userTypeDoc = await _firestore.collection('customers').doc(userId).get();

      if (userTypeDoc.exists) {
        return 'customer';
      }

      final DocumentSnapshot ownerTypeDoc = await _firestore.collection('owners').doc(userId).get();

      if (ownerTypeDoc.exists) {
        return 'owner';
      }

      return 'unknown'; // If neither customer nor owner is found
    } catch (e) {
      print('Error getting user type: $e');
      return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Lets in',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'HindSiliguri',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              'Manage your Dreams',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'HindSiliguri',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Email input field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            // Password input field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 55,
              width: double.maxFinite,
              child: TextButton(
                onPressed: _signInWithEmailAndPassword, // Call the sign-in function
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Color(0xffE7E2F9),
                ),
                child: Text(
                  "Sign In".toUpperCase(),
                  style: const TextStyle(color: Color(0xffB6A8ED)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
