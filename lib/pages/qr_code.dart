import 'package:dues/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class ShopQRCodePage extends StatelessWidget {
  final String shopName;
  final String? shopId=pre.getString('owner_uid');

   ShopQRCodePage({required this.shopName,});

  @override
  Widget build(BuildContext context) {
    String shopData = shopId ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           QrImageView(data: shopData),
            SizedBox(height: 20),
            Text('Scan this QR code to view shop details'),
          ],
        ),
      ),

    );
  }
}

