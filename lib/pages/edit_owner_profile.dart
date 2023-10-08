// edit_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../main.dart';

class EditOwnerProfile extends StatefulWidget {
  @override
  _EditOwnerProfileState createState() => _EditOwnerProfileState();
}

class _EditOwnerProfileState extends State<EditOwnerProfile> {
  // Create controllers for text fields
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nidController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final ownerID = pre.getString('owner_id');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: shopNameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),

            TextFormField(
              controller: nidController,
              decoration: InputDecoration(labelText: 'NID'),
            ),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateProfile();
                // Close the edit profile page
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // Implement the logic to update the profile in Firestore
  void _updateProfile() async {
    // Get the edited values from the text controllers
    final editedName = shopNameController.text;
    final editedAddress = addressController.text;
    final editedPhone = phoneController.text;
    final editedNID = nidController.text;

    // Validate the edited values (you can add more validation as needed)
    if (editedName.isEmpty || editedPhone.isEmpty ||editedNID.isEmpty || editedAddress.isEmpty) {
      // Show an error message if any field is empty
      EasyLoading.showError('Fill all the Fields');
      return; // Do not proceed with the update
    }

    try {
      // Perform the Firestore update
      await FirebaseFirestore.instance.collection('owners').doc(ownerID).update({
        'shopName': editedName,
        'phone': editedPhone,
        'nid': editedNID,
        'address': editedAddress,
      });

      // Show a success message
      EasyLoading.showSuccess('Successfully updated!');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Please Refresh This Page to See Changes')),
      );
      // Close the edit profile page

    } catch (error) {

      // Handle any potential errors that occur during the update
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Error updating profile: $error')),
      );
    }
  }
}
