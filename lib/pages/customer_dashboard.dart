import 'package:dues/pages/customer_profile.dart';
import 'package:dues/pages/my_shops.dart';
import 'package:badges/badges.dart' as custom_badge;
import 'package:dues/pages/qr_scanner.dart';
import 'package:dues/pages/shop_finder.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'sing_in.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  State<CustomerDashboard> createState() => CustomerDashboardState();
}

class CustomerDashboardState extends State<CustomerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Add a GlobalKey
  String? customerName; // Store the customer's name here


  @override
  void initState() {
    super.initState();
    // Fetch the customer's name from Firestore when the widget is initialized
    _fetchCustomerName();
  }

  void _fetchCustomerName() async {
    try {
      final userUid = _auth.currentUser?.uid;
      if (userUid != null) {
        final docSnapshot = await _firestore.collection('customers').doc(userUid).get();
        final customerData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          customerName = customerData['name'];
          pre.setString('name', customerName!);// Update the customerName variable
        });
      }
    } catch (e) {
      print('Error fetching customer name: $e');
    }
  }


  final ownerUid=pre.getString('owner_uid');


  Map<int, bool> showFullDate = {}; // Define the showFullDate map
  int currentIndex = 0; // Declare currentIndex here


  TextEditingController statusController = TextEditingController();





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('$customerName'),
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
                          hintText: "What's on your mind" ,
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            _shareStatus();
                          },
                          child: Text('Share'),
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
                child: FutureBuilder<QuerySnapshot>(
                  future: _firestore.collection('customers').doc(_auth.currentUser!.uid).collection('status').orderBy('timestamp', descending: true).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text('No Shared Status');
                    } else {
                      final statusesData = snapshot.data!.docs;
                      final statuses = <Widget>[];

                      for (var i = 0; i < statusesData.length; i++) {
                        final statusData = statusesData[i].data() as Map<String, dynamic>;
                        final statusText = statusData['statusText'] ?? '';
                        print('Status : $statusText');
                        final timestamp = statusData['timestamp'] ?? '';
                        final bool showFull = showFullDate[i] ?? false;

                        statuses.add(
                          Card(
                            elevation: 4.0,
                            margin: EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showFullDate[i] = !showFull;
                                      });
                                    },
                                    child: Text(
                                      showFull
                                          ? timestamp
                                          : '' + timestamp.split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    statusText,
                                    style: TextStyle(
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
                          initialPage: currentIndex,
                        ),
                        onPageChanged: (int index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'My Shops',
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
                builder: (context) => MyShops(),
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

  void _shareStatus() async {
    try {
      final statusText = statusController.text.trim();
      if (statusText.isNotEmpty) {
        final currentDate = DateTime.now();
        final formattedDate = currentDate.toLocal().toString();

        final customerData = {
          'statusText': statusText,
          'timestamp': formattedDate,
        };
        print('Status : $statusText');

        await _firestore
            .collection('customers')
            .doc(_auth.currentUser!.uid)
            .collection('status')
            .add(customerData);

        // Clear the text field after sharing
        statusController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status shared successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a status to share.'),
          ),
        );
      }
    } catch (e) {
      print('Error sharing status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while sharing the status.'),
        ),
      );
    }
  }
}