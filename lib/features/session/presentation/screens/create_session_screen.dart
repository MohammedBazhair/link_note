import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/screens/sign_in_screen.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../domain/entities/session.dart';
import '../controllers/session_controller.dart';

class CreateSessionPage extends ConsumerStatefulWidget {
  const CreateSessionPage({super.key});

  @override
  ConsumerState<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends ConsumerState<CreateSessionPage> {
  Future<void> _createSession() async {
    final loading = ref.read(loadingProvider.notifier);
    loading.state = true;

    final hostId = ref.read(userControllerProvider).profile.userId;

    final session = Session(hostId: hostId);

    await ref.read(sessionControllerProvider.notifier).createSession(session);

    loading.state = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (_, ref, __) {
                final isLoading = ref.watch(loadingProvider);
                return isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _createSession,
                        child: const Text('Create Session'),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
