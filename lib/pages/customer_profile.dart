import 'package:dues/pages/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class CustomerProfile extends StatefulWidget {
  @override
  _CustomerProfileState createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final customerID = pre.getString('user_id');




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('My Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('customers').doc(customerID).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Customer not found'));
          } else {
            final customerData = snapshot.data!.data() as Map<String, dynamic>;

            // Retrieve customer information
            final name = customerData['name'] ?? 'N/A';
            final Phone = customerData['phone'] ?? 'N/A';
            final email = customerData['email'] ?? 'N/A';
            final NID = customerData['nid'] ?? 'N/A';
            final address = customerData['address'] ?? 'N/A';




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
                          customerData['imageUrl'] ?? '', // Replace with the image URL key from your Firestore data
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Card(
                    elevation: 3,
                    child: Column(
                      children: [
                        _buildDetailRow('Name    :', name),
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
                backgroundColor: Colors.blueGrey,
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
