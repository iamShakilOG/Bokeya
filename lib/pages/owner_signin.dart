// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../main.dart';
// import 'owner_dashboard.dart';
//
// class SignIn2 extends StatefulWidget {
//   const SignIn2({Key? key}) : super(key: key);
//
//   @override
//   State<SignIn2> createState() => _SignIn2State();
// }
//
// class _SignIn2State extends State<SignIn2> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkLoggedIn(); // Check if the owner is already logged in
//   }
//
//   _checkLoggedIn() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final bool isLoggedIn = prefs.getBool('owner_logged_in') ?? false;
//
//     if (isLoggedIn) {
//       // If the owner is logged in, navigate to the dashboard
//       Get.to(() => const OwnerDashboard());
//     }
//   }
//
//   _setLoggedIn() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool('owner_logged_in', true);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(28),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 30),
//             const Text(
//               'Owner',
//               style: TextStyle(
//                 fontSize: 25,
//                 fontFamily: 'HindSiliguri',
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(
//               height: 10.0,
//             ),
//             const Text(
//               'Manage your Dreams',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontFamily: 'HindSiliguri',
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//
//             // Email input field
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                 hintText: 'Email',
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Password input field
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 hintText: 'Password',
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             SizedBox(
//               height: 55,
//               width: double.maxFinite,
//               child: TextButton(
//                 onPressed: () async {
//                   final FirebaseAuth auth = FirebaseAuth.instance;
//                   try {
//                     final UserCredential userCredential = await auth.signInWithEmailAndPassword(
//                       email: _emailController.text,
//                       password: _passwordController.text,
//                     );
//
//                     // Check if the sign-in was successful
//                     if (userCredential.user != null) {
//                       // Fetch additional user data from Firestore
//                       final userDoc = await _firestore.collection('owners').doc(userCredential.user!.uid).get();
//                       if (userDoc.exists) {
//                         _setLoggedIn();
//                         pre.setString('owner_id', userCredential.user!.uid.toString());
//                         Get.to(() => const OwnerDashboard());
//                         var ownerId = pre.getString("owner_id");
//                         print("ownerId value: $ownerId");
//                         // Get the user data and do something with it
//                         Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//                         print('User Data: $userData');
//                       }
//
//                       Get.to(() => const OwnerDashboard());
//                     }
//                   } catch (e) {
//                     print("Error signing in: $e");
//                     // Display an error message to the user
//                   }
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: const Color(0xffE7E2F9),
//                 ),
//                 child: Text(
//                   "Sign In".toUpperCase(),
//                   style: const TextStyle(color: Color(0xffB6A8ED)),
//                 ),
//               ),
//             ),
//
//             // ... other UI elements ...
//
//           ],
//         ),
//       ),
//     );
//   }
// }
