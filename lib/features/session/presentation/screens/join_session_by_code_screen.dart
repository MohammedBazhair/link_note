import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/loading_button.dart';
import '../../../qr_code/presentation/screens/scanner_qr_code_screen.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../controllers/session_controller.dart';
import '../controllers/session_state.dart';
import 'session_screen.dart';

class JoinSessionByCodeScreen extends ConsumerStatefulWidget {
  const JoinSessionByCodeScreen({super.key});
  @override
  ConsumerState<JoinSessionByCodeScreen> createState() =>
      _JoinSessionByCodePageState();
}

class _JoinSessionByCodePageState
    extends ConsumerState<JoinSessionByCodeScreen> {
  final _codeController = TextEditingController();

  Future<void> _join() async {
    _codeController.text.trim();
    final sessionCode = _codeController.text.trim().toUpperCase();
    if (sessionCode.isEmpty) {
      context.showSnakbar('الرجاء إدخال رمز الجلسة');
      return;
    }

    final controller = ref.read(sessionControllerProvider.notifier);
    final userId = ref.read(userControllerProvider).profile.userId;
    await controller.joinSessionByCode(
      memberId: userId,
      sessionCode: sessionCode,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionControllerProvider, (_, next) {
      if (next is JoinSessionState) {
        context.showSnakbar('تم الانضمام إلى الجلسة بنجاح');
        context.pushTo(const SessionScreen());
      } else if (next case ErrorSessionState(:final message)) {
        context.showSnakbar(message);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('الانضمام إلى الجلسة')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('رمز الجلسة:'),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,

                decoration: InputDecoration(
                  hintText: 'DH5T8',
                  suffixIcon: Platform.isWindows
                      ? null
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IconButton(
                            onPressed: () async {
                              final data = await context.pushTo<String?>(
                                const ScannerQrCodeScreen(),
                              );
                              _codeController.text =
                                  data ?? _codeController.text;
                            },
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              MainButton(onPressed: _join, text: 'انضم'),
            ],
          ),
        ),
      ),
    );
  }
}
