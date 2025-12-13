import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/loading_button.dart';
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
      context.showSnakbar('Please enter a session code');
      return;
    }

    final loading = ref.read(loadingProvider.notifier);
    loading.state = true;
    final controller = ref.read(sessionControllerProvider.notifier);
    final userId = ref.read(userControllerProvider).profile.userId;
    await controller.joinSessionByCode(memberId: userId,sessionCode:sessionCode);
    loading.state = false;
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
        context.showSnakbar('Joined to the session successfully');
        context.pushTo(const SessionScreen());
      } else if (next case ErrorSessionState(:final message)) {
        context.showSnakbar(message);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Join Session')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Session Code:'),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,

                decoration: const InputDecoration(hintText: 'DH5T8'),
              ),
              const SizedBox(height: 24),
              LoadingButton(onPressed: _join, text: 'Join'),
            ],
          ),
        ),
      ),
    );
  }
}
