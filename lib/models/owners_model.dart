class OwnersModel {
  String? ownerId;
  String? email;
  String? shopName;
  String? phone;
  String? imageURL;
  String? type; // Add a 'type' field

  OwnersModel({
    this.ownerId,
    this.email,
    this.shopName,
    this.phone,
    this.imageURL,
    required this.type, // Make 'type' a required parameter
  });

  factory OwnersModel.fromMap(Map<String, dynamic> map) => OwnersModel(
    ownerId: map['ownerId'],
    email: map['email'],
    shopName: map['shopName'],
    phone: map['phone'],
    imageURL: map['imageURL'],
    type: map['type'], // Initialize 'type' from the map
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ownerId': ownerId,
      'shopName': shopName,
      'email': email,
      'phone': phone,
      'imageURL': imageURL,
      'type': type, // Include 'type' in the map
    };
  }
}
