import 'package:dues/pages/customer_dashboard.dart';
import 'package:dues/pages/qr_scanner.dart';
import 'package:dues/pages/shop_finder.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'add_customer_dues.dart';

class MyShops extends StatefulWidget {
  const MyShops({super.key});

  @override
  _MyShopsState createState() => _MyShopsState();
}

class _MyShopsState extends State<MyShops> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userID = pre.getString('user_id');



  void _navigateToAddCustomerDues(String shopId, String cusId, String cusName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerDues(
          ownerId: shopId,
          cutomerName: cusName,
          cutomerId: cusId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('My Shops'),
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
              title: Text('My Profile'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('customers').doc(userID).collection('shoplist').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Shop Details Found'),
            );
          } else {
            final shopDocs = snapshot.data!.docs;
            final shopCards = shopDocs.map((shopDoc) {
              final shopData = shopDoc.data() as Map<String, dynamic>;
              final shopName = shopData['shopName'] ?? 'N/A';
              final email = shopData['email'] ?? 'N/A';
              final shopId = shopData['owner_uid'];
              final cusId = pre.getString('user_id');
              final cusName = pre.getString('name');
              final imageURL = shopData['imageUrl']; // Retrieve the imageURL
              print('shopId:$shopId');
              print('custID:$cusId');
              print('custName:$cusName');


              return Card(
                elevation: 7.0, // Add elevation for a shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Add rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0), // Add extra padding
                  child: ListTile(
                    onTap: () {
                      _navigateToAddCustomerDues(shopId, cusId!, cusName!);
                    },
                    leading: Container(
                      height: 80,
                      width: 80, // Adjust the width to make it narrower
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Make it circular
                        border: Border.all(
                          color: Colors.blue, // Add a border color
                          width: 2.0, // Set the border width
                        ),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(imageURL ?? ''),
                        ),
                      ),
                    ),
                    title: Text(
                      '$shopName',
                      style: TextStyle(
                        fontSize: 18.0, // Increase font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Email: $email',
                      style: TextStyle(
                        fontSize: 14.0, // Increase font size
                      ),
                    ),
                  ),
                ),
              );




            }).toList();

            return ListView(
              children: shopCards,
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Shop Finder',
          ),
        ],
        onTap: (int index) {
          // Handle navigation when an item is tapped
          if (index == 0) {
            // Navigate to MyShops page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDashboard(),
              ),
            );
          } else if (index == 1) {
            // Navigate to QRCodeScannerPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRCodeScannerPage(),
              ),
            );
          } else if (index == 2) {
            // Navigate to ShowAllDuesPage (replace this with the actual page)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopFinder(),
              ),
            );
          }
        },
      ),
    );
  }
}
