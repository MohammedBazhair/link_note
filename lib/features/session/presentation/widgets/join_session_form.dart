import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/loading_button.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';

class JoinSessionForm extends StatelessWidget {
  const JoinSessionForm({
    super.key,
    required this.controller,
    required this.onJoin,
  });
  final TextEditingController controller;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('join'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'DH5T8',
            labelText: 'رمز الجلسة',
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
        MainButton(onPressed: onJoin, text: 'انضم للجلسة'),
      ],
    );
  }
}
