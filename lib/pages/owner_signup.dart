// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// import '../models/owners_model.dart';
// import 'owner_signin.dart';
//
//
//
//
// class SignUp2 extends StatefulWidget {
//   const SignUp2({Key? key}) : super(key: key);
//
//   @override
//   State<SignUp2> createState() => _SignUp2State();
// }
//
// class _SignUp2State extends State<SignUp2> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//
//   File? _pickedImage;
//
//   void _togglePasswordVisibility() {
//     setState(() {
//       _obscurePassword = !_obscurePassword;
//     });
//   }
//
//   void _toggleConfirmPasswordVisibility() {
//     setState(() {
//       _obscureConfirmPassword = !_obscureConfirmPassword;
//     });
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedImage != null) {
//       setState(() {
//         _pickedImage = File(pickedImage.path);
//       });
//     }
//   }
//
//   Future<void> _createAccount() async {
//     EasyLoading.show(status: 'Creating Account...');
//
//     final auth = FirebaseAuth.instance;
//     final firestore = FirebaseFirestore.instance;
//
//     try {
//       final userCredential = await auth.createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//
//       final user = userCredential.user;
//       if (user != null) {
//         final userUid = user.uid;
//
//         final imageURL = await _uploadImageToStorage(userUid);
//
//         final owner = OwnersModel(
//           shopName: _nameController.text,
//           email: _emailController.text,
//           phone: _phoneController.text, // Store the phone number
//           ownerId: userUid,
//           imageURL: imageURL,
//           type: 'owners'
//         );
//
//         try {
//           await firestore.collection('owners').doc(userUid).set(owner.toMap());
//
//           _nameController.clear();
//           _emailController.clear();
//           _phoneController.clear();
//           _passwordController.clear();
//           _confirmPasswordController.clear();
//           _pickedImage = null;
//
//           Get.to((const SignIn2()));
//           EasyLoading.showToast('Done');
//
//         } catch (e) {
//           print('Error storing data in Firestore: $e');
//
//         }
//       }
//     } catch (e) {
//       print('Error creating user: $e');
//       EasyLoading.showToast('Invalid Email or Password');
//       EasyLoading.dismiss();
//     }
//   }
//
//   Future<String?> _uploadImageToStorage(String userUid) async {
//     if (_pickedImage == null) {
//       return null;
//     }
//
//     try {
//       final storage = FirebaseStorage.instance;
//       final imageRef = storage.ref().child('users/$userUid/profile.jpg');
//
//       final uploadTask = imageRef.putFile(_pickedImage!);
//       final snapshot = await uploadTask;
//       final downloadURL = await snapshot.ref.getDownloadURL();
//
//       return downloadURL;
//     } catch (e) {
//       print('Error uploading image to storage: $e');
//       return null;
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Owner Sign Up'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Shop Name'),
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _phoneController,
//               decoration: const InputDecoration(labelText: 'Phone Number'),
//             ),
//             TextField(
//               controller: _passwordController,
//               obscureText: _obscurePassword,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 suffixIcon: IconButton(
//                   onPressed: _togglePasswordVisibility,
//                   icon: Icon(
//                     _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                   ),
//                 ),
//               ),
//             ),
//             TextField(
//               controller: _confirmPasswordController,
//               obscureText: _obscureConfirmPassword,
//               decoration: InputDecoration(
//                 labelText: 'Confirm Password',
//                 suffixIcon: IconButton(
//                   onPressed: _toggleConfirmPasswordVisibility,
//                   icon: Icon(
//                     _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: const Text('Pick Image'),
//             ),
//             ElevatedButton(
//               onPressed: _createAccount,
//               child: const Text('Sign Up'),
//             ),
//             const SizedBox(height: 20),
//
//
//             _pickedImage != null
//                 ? Image.file(_pickedImage!)
//                 : const SizedBox.shrink(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
