import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../../core/constants/colors/colors.dart';

class GenerateQrCodeScreen extends StatelessWidget {
  const GenerateQrCodeScreen({super.key, required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رمز QR')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xC5FFFFFF), width: 0.3),
                borderRadius: BorderRadius.circular(13),
                boxShadow: const [BoxShadow(color: Color(0xFF00FFDD))],
                gradient: LinearGradient(
                  colors: [
                    DarkColors.primary.withOpacity(0.9),
                    DarkColors.primary.withOpacity(0.75),
                    DarkColors.primary.withOpacity(0.6),
                  ],
                ),
              ),
              child: Column(
                spacing: 12,
                children: [
                  QrCodeWidget(data: data),
                  const Text(
                    'أصبح الرمز جاهزاالان..\n يمكنك تحميله أو مشاركته مع أصدقائك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      height: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('تحميل')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text('مشاركة')),
          ],
        ),
      ),
    );
  }
}

class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      clipBehavior: Clip.antiAlias,
      width: screenWidth * 0.45,
      height: screenWidth * 0.45,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      child: PrettyQrView.data(
        data: data,
        errorBuilder: (context, error, stackTrace) => Text(
          error.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        decoration: const PrettyQrDecoration(
          background: Color(0xFBFFFFFF),

          quietZone: PrettyQrPixelsQuietZone(22),
        ),
      ),
    );
  }
}
