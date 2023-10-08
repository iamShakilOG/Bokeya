import 'package:dues/pages/qr_scanner.dart';
import 'package:dues/pages/shop_finder.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../main.dart';
import '../models/owners_model.dart';
import 'my_shops.dart';

class ShopDetailsPage extends StatefulWidget {
  final OwnersModel ownersModel;

  ShopDetailsPage({required this.ownersModel});

  @override
  _ShopDetailsPageState createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Shop Finder'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black38, // Change the color of the Drawer button here
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
              title: Text('My profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/shopFinder');
              },
            ),
            ListTile(
              title: Text('MyShops'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyShops(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Shop Finder'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopFinder(),
                  ),
                );
              },
            ),

            ListTile(
              title: Text('QR Scan'),
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
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Display shop image as a full-width image with border
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
                  child: Image.network(
                    widget.ownersModel.imageURL ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Display shop details using the OwnersModel
            Card(
              elevation: 3,
              child: Column(
                children: [
                  _buildDetailRow('Name    :', widget.ownersModel.shopName),
                  _buildDetailRow('Phone   :', widget.ownersModel.phone),
                  _buildDetailRow('Email   :', widget.ownersModel.email),
                  // Add more details as needed
                ],
              ),
            ),
          ],
        ),
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

  Future<void> _sendRequestForDues() async {
    var customerId = pre.getString("user_id");

    // Create a new request with ownerModel data
    Map<String, dynamic> request = {
      'customer_id': customerId,
      'owner_id': widget.ownersModel.ownerId,
      'imageURL': widget.ownersModel.imageURL,
    };

    try {
      await _firestore.collection('requests').add(request);
      EasyLoading.showToast('Request Sent Successfully');
    } catch (e) {
      print('Error sending request for dues: $e');
      EasyLoading.showToast('Request Sent Failed');
    }
  }

// ... other methods ...
}
