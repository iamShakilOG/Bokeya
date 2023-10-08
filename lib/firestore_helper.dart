import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/customer_model.dart';
import 'models/owners_model.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Insert owner data into Firestore
  Future<void> insertOwner(OwnersModel owner) async {
    try {
      await _firestore.collection('owners').add(owner.toMap());
    } catch (e) {
      print('Error inserting owner data: $e');
    }
  }

  // Retrieve owner accounts from Firestore
  Future<List<OwnersModel>> getOwnerAccounts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('owners').get();
      return querySnapshot.docs.map((doc) => OwnersModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error retrieving owner accounts: $e');
      return [];
    }
  }

  // Insert customer data into Firestore
  Future<void> insertCustomer(CustomersModel customer) async {
    try {
      await _firestore.collection('customers').add(customer.toMap());
    } catch (e) {
      print('Error inserting customer data: $e');
    }
  }

  // Retrieve customer accounts from Firestore
  Future<List<CustomersModel>> getCustomerAccounts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('customers').get();
      return querySnapshot.docs.map((doc) => CustomersModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error retrieving customer accounts: $e');
      return [];
    }
  }
}
