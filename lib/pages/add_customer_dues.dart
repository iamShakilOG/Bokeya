import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:dues/models/owners_model.dart';
import 'package:dues/pages/all_dues.dart';
import '../main.dart';

class AddCustomerDues extends StatefulWidget {
  String? cutomerId;
  String? cutomerName;
  String? ownerId;
  String? shopName;

  AddCustomerDues({Key? key, this.cutomerId, this.ownerId, this.cutomerName, this.shopName,})
      : super(key: key);

  @override
  State<AddCustomerDues> createState() => _AddCustomerDuesState();
}

class _AddCustomerDuesState extends State<AddCustomerDues> {
  final duesController = TextEditingController();

  String time = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _selectedDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        time = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(

          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              Text(widget.cutomerName ?? ""),
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.only(left: 15, right: 15),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(150),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _selectedDate,
                        child: const Text(
                          'Select Date ',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(time),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: duesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter your dues",
                  labelText: "Dues",
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  EasyLoading.show(status: 'loading...', dismissOnTap: false);

                  final ownerID = widget.ownerId ?? pre.getString('owner_id');
                  final customerId =widget.cutomerId ?? pre.getString('user_id');
                  print('CustomerID: $customerId');
                  Map<String, dynamic> map = {
                    'date': time,
                    'dues': duesController.text,
                    'customer_name': widget.cutomerName,
                    'customer_id': widget.cutomerId ?? customerId,
                  };

                  await _firestore
                      .collection('owners')
                      .doc(ownerID)
                      .collection('dues_list')
                      .doc()
                      .set(map);
                  EasyLoading.showSuccess('Great Success!');
                  EasyLoading.dismiss();
                  print('Data updated');
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xffff3333),
                  ),
                  child: const Center(
                    child: Text(
                      'Save Dues',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Add some spacing between buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AllDuesPage(ownerId: widget.ownerId ??'', custID: widget.cutomerId ?? '',))
      );},
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue,
                      ),
                      child: const Center(
                        child: Text(
                          'Show All Dues',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
