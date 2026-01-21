import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../domain/entities/qr_data.dart';
import '../controller/qr_providers.dart';
import 'scanner_qr_code_screen.dart';

class GenerateQrCodeScreen extends ConsumerWidget {
  const GenerateQrCodeScreen({super.key, required this.data});
  final QrData data;

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(qrControllerProvider, (_, state) {
      handleQrStates(context, state);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('رمز QR')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xC5FFFFFF),
                    width: 0.3,
                  ),
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
                    if (data.name case final String name when name.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 2,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    QrCodeWidget(data: data.qrCodeRaw),
                    const Text(
                      'أصبح الرمز جاهزاالان..\n يمكنك تحميله أو مشاركته مع أصدقائك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xEDFFFFFF),
                        height: 2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (_, ref, __) {
                  final controller = ref.read(qrControllerProvider.notifier);
                  return ElevatedButton(
                    onPressed: () => controller.saveQrAsImage(data),
                    child: const Text('تحميل'),
                  );
                },
              ),
            ],
          ),
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
