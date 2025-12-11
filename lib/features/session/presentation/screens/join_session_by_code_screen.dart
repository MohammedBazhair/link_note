import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../controllers/session_controller.dart';

class JoinSessionByCodePage extends ConsumerStatefulWidget {
  const JoinSessionByCodePage({super.key});
  @override
  ConsumerState<JoinSessionByCodePage> createState() =>
      _JoinSessionByCodePageState();
}

class _JoinSessionByCodePageState extends ConsumerState<JoinSessionByCodePage> {
  final _codeController = TextEditingController();

  Future<void> _join() async {
    _codeController.text.trim();
    final sessionCode = _codeController.text.trim().toUpperCase();
    if (sessionCode.isEmpty) {
      context.showSnakbar('Please enter a session code');
      return;
    }

    final loading = ref.read(loadingProvider.notifier);
    final controller = ref.read(sessionControllerProvider.notifier);
    loading.state = true;

    await controller.joinSessionByCode(sessionCode);
    loading.state = false;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Session')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Session code'),
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (_, ref, __) {
                final _isLoading = ref.watch(loadingProvider);
                return ElevatedButton(
                  onPressed: _isLoading ? null : _join,
                  child: _isLoading
                      ? const LinearProgressIndicator()
                      : const Text('Join'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
