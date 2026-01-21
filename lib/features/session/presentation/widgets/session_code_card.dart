import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../clipboard/presentation/providers/clipboard_providers.dart';
import '../../../qr_code/domain/entities/qr_data.dart';
import '../../../qr_code/presentation/screens/generate_qr_code_screen.dart';
import '../controllers/session_providers.dart';

class SessionCodeCard extends ConsumerWidget {
  const SessionCodeCard( {super.key});


  @override
  Widget build(BuildContext context,ref) {
    final sessionCode = ref.watch(sessionProvider)?.sessionCode;
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
              text: 'كود الجلسة:',
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
            tooltip: 'نسخ',
            color: Colors.white,
            icon: const Icon(Icons.copy),
            onPressed: () async {
              if (sessionCode == null) {
                return context.showSnakbar('خطأ لم يتم النسخ');
              }
          
              await ref
                  .read(clipboardControllerProvider)
                  .copyToClipboard(sessionCode);
                return context.showSnakbar('تم نسخ كود الجلسة بنجاح');
          
            },
          ),
          IconButton(
            color: Colors.white,
            tooltip: 'توليد رمز QR',
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              if(sessionCode == null )return context.showSnakbar('لا يمكن توليد Qr رمز لانه لا يوجد كود للجلسة');
              final qrData= QrData(name: sessionCode,qrCodeRaw: sessionCode);

              context.pushTo(GenerateQrCodeScreen(data: qrData ));
            },
          ),
        ],
      ),
    );
  }
}
