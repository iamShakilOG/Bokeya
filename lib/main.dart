import 'package:dues/pages/customer_dashboard.dart';
import 'package:dues/pages/owner_dashboard.dart'; // Import the OwnerDashboard
import 'package:dues/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

late SharedPreferences pre;
late SharedPreferences ownerPre; // Separate SharedPreferences for owners

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  pre = await SharedPreferences.getInstance();
  ownerPre = await SharedPreferences.getInstance(); // Initialize ownerPre
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    // Check if the customer is already logged in using SharedPreferences
    bool isCustomerLoggedIn = pre.getBool('customerLoggedIn') ?? false;

    // Check if the owner is already logged in using SharedPreferences
    bool isOwnerLoggedIn = pre.getBool('ownerLoggedIn') ?? false;

    // Determine which dashboard to show based on login status
    Widget initialRoute = isCustomerLoggedIn ?  CustomerDashboard() : isOwnerLoggedIn ? const OwnerDashboard() : const HomePage();

    return GetMaterialApp(
      title: 'Bokeya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
      // Use the appropriate initialRoute based on login status
      home: initialRoute,
    );
  }
}
