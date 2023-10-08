import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dues/main.dart';
import 'package:dues/models/owners_model.dart';
import 'package:intl/intl.dart';

import 'edit_owner_profile.dart';

class AllDuesPage extends StatefulWidget {
  final String? ownerId;
  final String? custID;
  final String? userType; // Add userType as a parameter

  AllDuesPage({required this.ownerId, required this.custID, this.userType});

  @override
  _AllDuesPageState createState() => _AllDuesPageState();
}

class _AllDuesPageState extends State<AllDuesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalDues = 0.0; // Variable to hold the total dues
  final TextEditingController paymentController = TextEditingController();
  final userType =pre.getString('type');

  @override
  void initState() {
    super.initState();
    _calculateTotalDues();
  }

  Future<void> _makePayment() async {
  // Check if shopName is not null

    try {
      final paymentAmount = double.tryParse(paymentController.text) ?? 0.0;
      if (paymentAmount > 0) {
        final currentDate = DateTime.now();
        final formattedDate = DateFormat.yMd().format(currentDate); // Format the date as desired

        // Assuming you have a customer_id to identify the customer
        final customerID = widget.custID;
        final name = pre.getString('name');

        // Add payment as a negative amount to indicate it's a payment
        final duesData = {
          'customer_id': customerID,
          'customer_name': name, // Replace with the actual customer's name
          'date': formattedDate,
          'dues': (-paymentAmount).toString(), // Negative value for payment
        };

        await _firestore
            .collection('owners')
            .doc(widget.ownerId)
            .collection('dues_list')
            .add(duesData);

        // Clear the text field after making the payment
        paymentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment made successfully.'),
          ),
        );

        // Recalculate total dues after making a payment
        await _calculateTotalDues();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid payment amount.'),
          ),
        );
      }
    } catch (e) {
      print('Error making payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while making the payment.'),
        ),
      );
    }
  }

  Future<void> _deleteDues(String docId) async {
    try {
      final duesDoc = await _firestore
          .collection('owners')
          .doc(widget.ownerId)
          .collection('dues_list')
          .doc(docId)
          .get();

      if (duesDoc.exists) {
        await _firestore
            .collection('owners')
            .doc(widget.ownerId)
            .collection('dues_list')
            .doc(docId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dues deleted successfully.'),
          ),
        );

        // Recalculate total dues after deletion
        await _calculateTotalDues();
      }
    } catch (e) {
      print('Error deleting dues: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while deleting dues.'),
        ),
      );
    }
  }

  Future<void> _calculateTotalDues() async {
    try {
      final snapshot = await _firestore
          .collection('owners')
          .doc(widget.ownerId)
          .collection('dues_list')
          .where('customer_id', isEqualTo: widget.custID)
          .get();

      if (snapshot.docs.isNotEmpty) {
        totalDues = snapshot.docs
            .map<double>((duesDoc) {
          final duesData = duesDoc.data() as Map<String, dynamic>;
          final dues = double.tryParse(duesData['dues'] ?? '0.0') ?? 0.0;
          return dues;
        })
            .fold<double>(0.0, (previousValue, dues) => previousValue + dues);
      }

      setState(() {});
    } catch (e) {
      print('Error calculating total dues: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = userType == 'owners'; // Check if ownerId is not null

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Dues'),
        actions: [
          // Conditionally show the edit button for owners
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to EditOwnerProfile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditOwnerProfile(),
                  ),
                );
              },
            ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
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
      body: Column(
        children: [
          if (isOwner)
          // Conditionally show the payment section for owners
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: paymentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter payment amount',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _makePayment,
                    child: const Text('Pay'),
                  ),
                ],
              ),
            ),
          // Dues List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('owners')
                  .doc(widget.ownerId)
                  .collection('dues_list')
                  .where('customer_id', isEqualTo: widget.custID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No Dues Found'));
                } else {
                  final duesDocs = snapshot.data!.docs;

                  if (duesDocs.isEmpty) {
                    return const Center(child: Text('No Dues Found for this Customer'));
                  }

                  return ListView.builder(
                    itemCount: duesDocs.length,
                    itemBuilder: (context, index) {
                      final duesData = duesDocs[index].data() as Map<String, dynamic>;
                      final docId = duesDocs[index].id;
                      final date = duesData['date'] ?? '';
                      final dues = duesData['dues'] ?? '';

                      return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to both ends
                            children: [
                              Text('$date'),
                              Row(
                                children: [
                                  Text('$dues'),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteDues(docId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8.0, // Add elevation for a shadow effect
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Add padding
          decoration: const BoxDecoration(
            color: Colors.blueGrey, // Set background color
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)), // Add rounded corners
          ),
          height: 80.0, // Increase the height
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to both ends
            children: [
              const Text(
                'Total Dues',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\৳$totalDues'' Taka',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
