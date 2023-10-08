import 'package:dues/main.dart';
import 'package:dues/pages/owner_dashboard.dart';
import 'package:dues/pages/request_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'add_customer_dues.dart';
import 'owner_profile.dart';

class MyCustomers extends StatefulWidget {
  const MyCustomers({Key? key}) : super(key: key);

  @override
  _MyCustomersState createState() => _MyCustomersState();
}

class _MyCustomersState extends State<MyCustomers> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  final ownerId=pre.getString('owner_id');
  // @override
  // void initState() {
  //   super.initState();
  //   _loadSharedPreferences();
  // }
  //
  // Future<void> _loadSharedPreferences() async {
  //   _preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     ownerId = _preferences.getString('owner_uid');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text('My Customers'),
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
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerDashboard(),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('owners').doc(ownerId).collection('customerlist').snapshots(),
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
              child: Text('No Customers Yet'),
            );
          } else {
            final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                final customerData = doc.data() as Map<String, dynamic>;

                final customerName = customerData['name'] ?? 'N/A';
                final customerPhone = customerData['phone'] ?? 'N/A';
                final customerId = customerData['customerId'];
                final customerImage = customerData['imageUrl'] ?? 'N/A';

                final shopName = pre.getString('shopName')?? 'N/A';
                print('shopName:$shopName');

                print('Customer Data: $customerName, $customerPhone, $customerId');

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      // Load image from the retrieved imageURL
                      backgroundImage: NetworkImage(customerImage),
                      radius: 25,
                    ),
                    title: Text('$customerName'),
                    subtitle: Text('Phone: $customerPhone'),
                    onTap:() =>Navigator.push(context, MaterialPageRoute(builder: (_)=>AddCustomerDues(cutomerName: customerName,cutomerId: customerId,ownerId: ownerId ,shopName:shopName ??'',))),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
