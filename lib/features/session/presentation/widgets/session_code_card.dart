import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../qr_code/presentation/screens/generate_qr_code_screen.dart';

class SessionCodeCard extends StatelessWidget {
  const SessionCodeCard(this.sessionCode, {super.key});

  final String? sessionCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              text: 'Code:',
              style: const TextStyle(
                color: Color(0xE2FFFFFF),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: '    '),
                TextSpan(
                  text: sessionCode ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Copy',
            color: Colors.white,
            icon: const Icon(Icons.copy),
            onPressed: () {
              // TODO: implement copy to clipboard
            },
          ),
          IconButton(
            color: Colors.white,
            tooltip: 'Generate QR Code',
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              context.pushTo(GenerateQrCodeScreen(data: sessionCode ?? ''));
            },
          ),
        ],
      ),
    );
  }
}
