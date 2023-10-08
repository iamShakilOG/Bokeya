import 'package:dues/pages/edit_owner_profile.dart';
import 'package:dues/pages/edit_profile.dart';
import 'package:dues/pages/owner_dashboard.dart';
import 'package:dues/pages/request_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'home_page.dart';
import 'my_customer.dart';

class OwnerProfile extends StatefulWidget {
  @override
  _OwnerProfileState createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> getOwnerDetails(String shopName, String email, String ownerUid, String ImageURL,String userType) async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    pre.setString('shopName', shopName);
    pre.setString('email', email);
    pre.setString('owner_uid', ownerUid);
    pre.setString('imageUrl', ImageURL);
    pre.setString('type', userType);
    EasyLoading.dismiss();
  }

  final ownerID = pre.getString('owner_id');




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text('My Profile'),
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
        actions: [
          // Add an "Edit Profile" button to the AppBar
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to the EditOwnerProfile page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  EditOwnerProfile(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
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
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OwnerDashboard(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('My Customers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyCustomers(),
                  ),
                );
              },
            ),


            ListTile(
              title: const Text('Payments'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // ... navigate to payments page ...
              },
            ),
            ListTile(
              title: const Text('Request List'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerRequestList(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () async {
                // Clear owner-related SharedPreferences
                await ownerPre.clear();

                // Sign out the user
                await FirebaseAuth.instance.signOut();

                // Navigate back to the login page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false, // This prevents the user from going back to the dashboard
                );
              },
            ),


          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('owners').doc(ownerID).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Customer not found'));
          } else {
            final shopData = snapshot.data!.data() as Map<String, dynamic>;

            // Retrieve owners information
            final shopName = shopData['shopName'] ?? 'N/A';
            final Phone = shopData['phone'] ?? 'N/A';
            final email = shopData['email'] ?? 'N/A';
            final NID = shopData['nid'] ?? 'N/A';
            final address = shopData['address'] ?? 'N/A';
            final ImageURL = shopData['imageURL'] ?? 'N/A';
            final ownerUid = shopData['ownerId'] ?? 'N/A';
            final userType = shopData['type'] ?? 'N/A';

            getOwnerDetails(shopName, email, ownerUid,ImageURL,userType);
            print('ownerID: $ownerID');



            // Add any additional fields you want to display

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
                          shopData['imageURL'] ?? '', // Replace with the image URL key from your Firestore data
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
                        _buildDetailRow('Phone   :', Phone),
                        _buildDetailRow('Email   :', email),
                        _buildDetailRow('NID     :', NID),
                        _buildDetailRow('Address :', address),
                        // Add more details as needed
                      ],
                    ),
                  ),


                ],
              ),
            );
          }
        },
      ),// ... Existing code ...

      bottomNavigationBar: Container(
        margin: EdgeInsets.all(16.0),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the edit profile screen
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => EditProfilePage(),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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


// Create a separate screen for editing the profile
