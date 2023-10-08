import 'package:dues/pages/customer_profile.dart';
import 'package:dues/pages/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../models/owners_model.dart';
import 'customer_dashboard.dart';
import 'my_shops.dart';
import 'shop_details.dart';

// ... other imports ...

class ShopFinder extends StatefulWidget {
  const ShopFinder({super.key});

  @override
  _ShopFinderState createState() => _ShopFinderState();
}

class _ShopFinderState extends State<ShopFinder> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final OwnersModel ownersModel;

  int _previousLength = 0;

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
              title: Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerProfile(),
                  ),
                );
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
        stream: _firestore.collection('owners').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Shops Yet'),
            );
          } else {
            final List<DocumentSnapshot> ownerDocs = snapshot.data!.docs;

            if (_previousLength != ownerDocs.length) {
              _previousLength = ownerDocs.length;
            }

            return ListView.builder(
              itemCount: ownerDocs.length,
              itemBuilder: (context, index) {
                final ownerDoc = ownerDocs[index];
                final shopName = ownerDoc['shopName'] ?? 'N/A';
                final email = ownerDoc['email'] ?? 'N/A';
                final phone = ownerDoc['phone'] ?? 'N/A';
                final ownerId = ownerDoc['ownerId'] ?? 'N/A';
                final imageURL = ownerDoc['imageURL'] ?? ''; // Retrieve image URL from Firestore

                final model = OwnersModel(shopName: shopName, email: email, ownerId: ownerId, imageURL: imageURL, phone: phone, type: '');
                EasyLoading.dismiss();


                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        // Load image from the retrieved imageURL
                        backgroundImage: NetworkImage(imageURL),
                        radius: 40, // Set the desired image size
                      ),
                      title: Text(
                        shopName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        email,
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailsPage(
                              ownersModel: model,

                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );


              },
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
                builder: (context) => MyShops(),
              ),
            );
          }
        },
      ),
    );
  }
}
