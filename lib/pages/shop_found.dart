import 'package:dues/pages/qr_scanner.dart';
import 'package:dues/pages/shop_finder.dart';
import 'package:dues/pages/sing_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../main.dart';
import '../models/owners_model.dart';
import 'customer_profile.dart';
import 'my_shops.dart';

class ShopFoundPage extends StatelessWidget {
  final String shopId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ShopFoundPage({required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Shop Found'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black38,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>   CustomerProfile(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('MyShops'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyShops(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Shop Finder'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShopFinder(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('QR Scan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRCodeScannerPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Sign Out'),
              onTap: () async {
                // Perform the sign-out logic here
                await FirebaseAuth.instance.signOut();
                // Clear the saved login status using SharedPreferences
                pre.setBool('isLoggedIn', false);
                // Navigate back to the sign-in page
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SignIn(),
                ));
              },
            ),

          ],
        ),
      ),
      body: FutureBuilder(
        future: _fetchShopDetails(shopId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Display shop details

            final shopDetails = snapshot.data as Map<String, dynamic>;
            final shopName = shopDetails['shopName'] ?? 'N/A';
            final email = shopDetails['email'] ?? 'N/A';
            final phone = shopDetails['phone'] ?? 'N/A';
            final ownerId = shopDetails['ownerId'] ?? 'N/A';
            final imageURL = shopDetails['imageURL'] ?? '';
            pre.setString('imageURL', imageURL);
            final model = OwnersModel(shopName: shopName, email: email, ownerId: ownerId, imageURL: imageURL, phone: phone, type: '');
            EasyLoading.dismiss();

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Display customer image as a full-width image with border
                  Card(
                    elevation: 3,
                    margin: EdgeInsets.all(0), // Remove margin to have full-width card
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueGrey, // Set the border color
                          width: 8.0, // Set the border width
                        ),
                      ),
                      width: double.infinity,
                      height: 300, // Adjust the height as needed
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0), // Adjust border radius as needed
                        child: /* You can add an Image.network here */ Image.network(
                          shopDetails['imageURL'] ?? '', // Replace with the image URL key from your Firestore data
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Card(
                    elevation: 3,
                    child: Column(
                      children: [
                        _buildDetailRow('Name    :', shopName),
                        _buildDetailRow('Email   :', email),

                        // Add more details as needed
                      ],
                    ),
                  ),


                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _sendRequestForDues,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Send Request For Dues',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDetailRow(String label, String? value) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey, // Set the border color
          width: 8.0, // Set the border width
        ),
      ),
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Set the text color
                ),
              ),
              SizedBox(width: 8.0), // Add spacing between label and value
              Text(
                value ?? 'N/A', // Use 'N/A' as the default value if it's null
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown, // Set the text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<Map<String, dynamic>> _fetchShopDetails(String shopId) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final shopQuery = await firestore
          .collection('owners')
          .where('ownerId', isEqualTo: shopId)
          .get();
      print('shopId:$shopId');
      if (shopQuery.docs.isNotEmpty) {
        return shopQuery.docs.first.data() as Map<String, dynamic>;
      } else {
        throw 'Shop not found';
      }
    } catch (e) {
      throw 'Error fetching shop details: $e';
    }
  }

  Future<void> _sendRequestForDues() async {
    var customerId = pre.getString("user_id");
    var imageUrl = pre.getString('imageUrl');

    // Create a new request with ownerModel data
    Map<String, dynamic> request = {
      'customer_id': customerId,
      'owner_id': shopId ,
      'imageURL': imageUrl,
    };

    try {
      await _firestore.collection('requests').add(request);
      EasyLoading.showToast('Request Sent Successfully');
    } catch (e) {
      print('Error sending request for dues: $e');
      EasyLoading.showToast('Request Sent Failed');
    }
  }
}
