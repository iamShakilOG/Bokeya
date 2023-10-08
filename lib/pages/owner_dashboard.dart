import 'package:dues/main.dart';
import 'package:dues/pages/owner_profile.dart';
import 'package:dues/pages/qr_code.dart';
import 'package:dues/pages/request_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'my_customer.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => OwnerDashboardState();
}

class OwnerDashboardState extends State<OwnerDashboard> {
  final TextEditingController statusController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String? shopName=pre.getString('shopName');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text('My Dashboard'),
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
            DrawerHeader(
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
              title: Text('My profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerProfile(),
                  ),
                );// ... navigate to profile page ...
              },
            ),
            ListTile(
              title: Text('My Customers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyCustomers(),
                  ),
                );
              },
            ),


            ListTile(
              title: Text('Request List'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerRequestList(), // Pass the owner ID
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // ... handle logout ...
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 150.0,
              child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: statusController,
                        decoration: InputDecoration(
                          hintText: "What's on your mind",
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            _shareStatus();
                          },
                          child: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 200.0,
              width: 500,
              child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                color: Colors.grey[200],
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('owners')
                      .doc(_auth.currentUser!.uid)
                      .collection('status')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Text('No Shared Status');
                    } else {
                      final statusesData = snapshot.data!.docs;
                      final statuses = <Widget>[];

                      for (var i = 0; i < statusesData.length; i++) {
                        final statusData =
                        statusesData[i].data() as Map<String, dynamic>;
                        final statusText = statusData['statusText'] ?? '';
                        final timestamp = statusData['timestamp'] ?? '';
                        final bool showFull = false; // Change this accordingly

                        statuses.add(
                          Card(
                            elevation: 4.0,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Toggle showFull logic here
                                      setState(() {
                                        // Toggle showFull logic here
                                        // showFullDate[i] = !showFullDate[i];
                                      });
                                    },
                                    child: Text(
                                      showFull
                                          ? timestamp
                                          : '' + timestamp.split(' ')[0],
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    statusText,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return PageView.builder(
                        itemCount: statuses.length,
                        controller: PageController(
                          initialPage: 0,
                        ),
                        itemBuilder: (context, index) {
                          return statuses[index];
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),

        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopQRCodePage(shopName: shopName!,),
              ),
            );
          },
          child: const Text('Share QR Code'),

        ),
      ),
    );
  }

  void _shareStatus() async {
    try {
      final statusText = statusController.text.trim();
      if (statusText.isNotEmpty) {
        final currentDate = DateTime.now();
        final formattedDate = currentDate.toLocal().toString();

        final statusData = {
          'statusText': statusText,
          'timestamp': formattedDate,
        };

        await _firestore
            .collection('owners')
            .doc(_auth.currentUser!.uid)
            .collection('status')
            .add(statusData);

        // Clear the text field after sharing
        statusController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status shared successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a status to share.'),
          ),
        );
      }
    } catch (e) {
      print('Error sharing status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while sharing the status.'),
        ),
      );
    }
  }
}
