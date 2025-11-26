import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class GenerateQrCodeScreen extends StatelessWidget {
  const GenerateQrCodeScreen({super.key, required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF101818),
        title: Text("Generate QR Code"),
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      body: Center(
        child: Container(
          width: screenWidth * 0.5,
          height: screenWidth * 0.5,
          clipBehavior: Clip.antiAliasWithSaveLayer,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 2, ),
          ),
          child: PrettyQrView.data(
            data: data,
            errorBuilder: (context, error, stackTrace) => Text(
              error.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            decoration: const PrettyQrDecoration(
              background: Color(0xFFFFFFFF),
              quietZone: PrettyQrPixelsQuietZone(20),
            ),
          ),
        ),
      ),
    );
  }
}
