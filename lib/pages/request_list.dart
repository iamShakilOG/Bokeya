import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'my_customer.dart';
import 'owner_profile.dart';


class CustomerRequestList extends StatefulWidget {
  const CustomerRequestList({Key? key}) : super(key: key);

  @override
  State<CustomerRequestList> createState() => _CustomerRequestListState();
}

class _CustomerRequestListState extends State<CustomerRequestList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ownerID = pre.getString('owner_id');

  Future<Map<String, String>> getOwnerDetails() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    String? shopName = pre.getString('shopName');
    String? email = pre.getString('email');
    String? ownerUid = pre.getString('owner_uid');
    String? ImageURL = pre.getString('imageUrl');

    return {
      'shopName': shopName ?? '',
      'email': email ?? '',
      'owner_uid': ownerUid ?? '',
      'imageUrl' : ImageURL ?? '',

    };
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text('Requests'),
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('requests').snapshots(),
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
              child: Text('No Requests Yet'),
            );
          } else {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
                snapshot.data!.docs;

            // Filter requests that match the ownerId
            final filteredDocuments = documents
                .where((doc) => doc['owner_id'] == ownerID)
                .toList();
            return ListView.builder(
              itemCount: filteredDocuments.length,
              itemBuilder: (context, index) {
                final doc = filteredDocuments[index];
                final requestID = doc.id;
                final customerID = doc['customer_id'];

                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('customers').doc(customerID).get(),
                  builder: (context, customerSnapshot) {
                    if (customerSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (customerSnapshot.hasError) {
                      return Text('Error: ${customerSnapshot.error}');
                    } else if (!customerSnapshot.hasData || customerSnapshot.data!.data() == null) {
                      return const ListTile(
                        title: Text('Customer Data Unavailable'),
                      );
                    } else {
                      final customerData = customerSnapshot.data!.data() as Map<String, dynamic>;
                      final customerName = customerData['name'] ?? 'N/A';
                      final customerPhone = customerData['phone'] ?? 'N/A';
                      final customerImage = customerData['imageUrl'] ?? 'N/A';

                      return ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          // Load image from the retrieved imageURL
                          backgroundImage: NetworkImage(customerImage),
                          radius: 25,
                        ),

                        title: Text('$customerName'),
                        subtitle: Text('Phone: $customerPhone'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () async {

                                await _firestore.collection('requests').doc(doc.id).update({'status': 'accepted'});
                                EasyLoading.showToast('Request Accepted');
                                // Add a new document under the owner's "customerlist" collection
                                await _firestore.collection('owners').doc(ownerID).collection('customerlist').doc(customerID).set(customerData);

                                // Add owner details to the 'shoplist' under the customer's node
                                await _firestore.collection('customers').doc(customerID).collection('shoplist').doc(ownerID).set(await getOwnerDetails());

                                await _firestore.collection('requests').doc(requestID).delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Request Accepted'),

                                  ),
                                );
                              },
                            ),



                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () async {
                                // Perform reject action
                                // For example: delete request from Firestore
                                await _firestore.collection('requests').doc(requestID).delete();
                                EasyLoading.show(status: 'loading...');
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
