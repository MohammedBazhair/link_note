import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/loading_button.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../controllers/session_controller.dart';

class JoinSessionForm extends StatelessWidget {
  const JoinSessionForm({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        const Text('أدخل رمز الجلسة للانضمام إليها:'),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'DH5T8',
            helperText: 'الرمز مكون من 5 أحرف يمكنك كتابتها سمول أو كابيتال',
            suffixIcon: Platform.isWindows
                ? null
                : IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      final code = await context.pushTo<String?>(
                        const ScannerQrCodeScreen(),
                      );
                      if (code != null) controller.text = code;
                    },
                  ),
          ),
        ),
        const SizedBox(height: 30),
        Consumer(
          builder: (_, ref, __) {
            return MainButton(
              text: 'انضم للجلسة',
              onPressed: () async {
                final code = controller.text.trim().toUpperCase();

                if (code.isEmpty) {
                  context.showSnakbar('الرجاء إدخال رمز الجلسة');
                  return;
                }

                final userId = ref.read(userControllerProvider).profile.userId;

                await ref
                    .read(sessionControllerProvider.notifier)
                    .joinSessionByCode(memberId: userId, sessionCode: code);

              },
            );
          },
        ),
      ],
    );
  }
}
