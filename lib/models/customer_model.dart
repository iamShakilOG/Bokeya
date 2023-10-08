class CustomersModel {
  String? email;
  String? name;
  String? phone;
  String? customerID;
  String? imageURL;
  String? type; // Add a 'type' field

  CustomersModel({
    this.email,
    this.name,
    this.phone,
    this.customerID,
    this.imageURL,
    required this.type, // Make 'type' a required parameter
  });

  factory CustomersModel.fromMap(Map<String, dynamic> map) => CustomersModel(
    phone: map['phone'],
    email: map['email'],
    name: map['name'],
    customerID: map['customerID'],
    imageURL: map['imageUrl'],
    type: map['type'], // Initialize 'type' from the map
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'customerId': customerID,
      'imageUrl': imageURL,
      'type': type, // Include 'type' in the map
    };
  }
}
