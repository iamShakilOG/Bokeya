//
// import 'package:testing_project/models/customer_model.dart';
//
// import '../models/owners_model.dart';
//
//  class DBHelpers{
//  static final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//  static List<CustomersModel>  allCustomers = [];
//
//  static List<OwnersModel> allOwners =[];
//
//
//
//
//  static Future<void> getAllCustomer() async {
//    final snapshot = await _db.collection('customers').get();
//    allCustomers = List.generate(snapshot.docs.length,
//            (index) => CustomersModel.fromMap(snapshot.docs[index].data()));
//   }
//  static Future<void> getAllOwners() async {
//    final snapshot = await _db.collection('owners').get();
//    allOwners = List.generate(snapshot.docs.length,
//            (index) => OwnersModel.fromMap(snapshot.docs[index].data()));
//
//   }
//  static Stream<QuerySnapshot<Map<String, dynamic>>> getAll2() =>
//      _db.collection("owners").snapshots();
//
//
//   // List<ItemsModel>getSearchItems(num id){
//   //  searchAll.clear();
//   //  for( var i in allFood){
//   //   if(i.catId==id){
//   //    searchAll.add(i);
//   //   }
//   //  }
//   //
//   //  return searchAll;
//   // }
//
//  }